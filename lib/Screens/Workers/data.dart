//store the workers data fetched from the database
//to this class
import 'package:string_extension/string_extension.dart';

extension StringCasingExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.capitalize).join(" ");
}

class Data {
  String? databaseCategory,
      databaseName,
      databaseAddress,
      phoneNumber,
      photoURL;

  Data(this.databaseCategory, this.databaseName, this.databaseAddress,
      this.phoneNumber, this.photoURL);
}
