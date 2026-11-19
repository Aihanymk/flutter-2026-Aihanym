class Geo {
  const Geo({required this.lat, required this.lng});

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  static const empty = Address(
    street: '',
    suite: '',
    city: '',
    zipcode: '',
    geo: Geo(lat: 0, lng: 0),
  );

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };
}

typedef Company = ({String name, String catchPhrase});

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  const User.draft({
    required this.name,
    required this.username,
    required this.email,
  }) : id = 0,
       phone = '',
       website = null,
       address = Address.empty,
       company = (name: '', catchPhrase: '');

  factory User.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?, // the only optional field
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: company['name'] as String,
        catchPhrase: company['catchPhrase'] as String,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final Company company;

  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'address': address.toJson(),
    'phone': phone,
    if (website != null) 'website': website,
    'company': {'name': company.name, 'catchPhrase': company.catchPhrase},
  };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User($id, $name, $email, ${address.city})';
}
