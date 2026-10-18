import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:plant_care/services/plant_identifier_service.dart';

void main() {
  late Directory directory;
  late File image;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('plant_identifier_test_');
    image = File('${directory.path}/plant.png');
    await image.writeAsBytes(img.encodePng(img.Image(width: 1, height: 1)));
  });
  tearDown(() async => directory.delete(recursive: true));

  test('sends images to the documented Pl@ntNet multipart endpoint', () async {
    String? method;
    Uri? url;
    String? contentType;
    String? multipartBody;
    final client = MockClient((request) async {
      method = request.method;
      url = request.url;
      contentType = request.headers['content-type'];
      multipartBody = utf8.decode(request.bodyBytes, allowMalformed: true);
      return http.Response(jsonEncode(_successfulResponse), 200);
    });
    final result = await PlantIdentifierService(
      client: client,
      apiKey: 'test-key',
    ).identifyPlant(XFile(image.path));
    expect(method, 'POST');
    expect(
      url.toString(),
      contains('https://my-api.plantnet.org/v2/identify/all'),
    );
    expect(url!.queryParameters['api-key'], 'test-key');
    expect(url!.queryParameters['lang'], 'en');
    expect(contentType, startsWith('multipart/form-data'));
    expect(multipartBody, contains('name="images"'));
    expect(result.bestMatch!.commonName, 'Swiss cheese plant');
    expect(result.bestMatch!.displayName, 'Monstera deliciosa');
    expect(result.bestMatch!.score, 0.91);
    expect(result.bestMatch!.family, 'Araceae');
    expect(result.bestMatch!.genus, 'Monstera');
    expect(result.results, hasLength(2));
    expect(result.predictedOrgans, ['leaf']);
  });

  test('maps an invalid API key response to an authorization error', () async {
    final client = MockClient(
      (_) async => http.Response('{"error":"Unauthorized"}', 401),
    );
    await expectLater(
      PlantIdentifierService(
        client: client,
        apiKey: 'bad-key',
      ).identifyPlant(XFile(image.path)),
      throwsA(
        isA<PlantIdentifierException>().having(
          (error) => error.type,
          'type',
          PlantIdentifierErrorType.unauthorized,
        ),
      ),
    );
  });

  test('rejects unsupported image data before requesting the API', () async {
    final invalid = File('${directory.path}/invalid.txt');
    await invalid.writeAsString('not an image');
    var requestMade = false;
    final client = MockClient((_) async {
      requestMade = true;
      return http.Response('{}', 200);
    });
    await expectLater(
      PlantIdentifierService(
        client: client,
        apiKey: 'test-key',
      ).identifyPlant(XFile(invalid.path)),
      throwsA(
        isA<PlantIdentifierException>().having(
          (error) => error.type,
          'type',
          PlantIdentifierErrorType.invalidImage,
        ),
      ),
    );
    expect(requestMade, isFalse);
  });
}

const _successfulResponse = <String, dynamic>{
  'predictedOrgans': <Map<String, dynamic>>[
    <String, dynamic>{'organ': 'leaf'},
  ],
  'version': '2025-01-17 (7.3)',
  'remainingIdentificationRequests': 498,
  'results': <Map<String, dynamic>>[
    <String, dynamic>{
      'score': 0.91,
      'species': <String, dynamic>{
        'scientificName': 'Monstera deliciosa Liebm.',
        'scientificNameWithoutAuthor': 'Monstera deliciosa',
        'commonNames': <String>['Swiss cheese plant'],
        'genus': <String, String>{'scientificNameWithoutAuthor': 'Monstera'},
        'family': <String, String>{'scientificNameWithoutAuthor': 'Araceae'},
      },
    },
    <String, dynamic>{
      'score': 0.08,
      'species': <String, dynamic>{
        'scientificName': 'Monstera adansonii Schott',
        'scientificNameWithoutAuthor': 'Monstera adansonii',
        'commonNames': <String>["Adanson's monstera"],
        'genus': <String, String>{'scientificNameWithoutAuthor': 'Monstera'},
        'family': <String, String>{'scientificNameWithoutAuthor': 'Araceae'},
      },
    },
  ],
};
