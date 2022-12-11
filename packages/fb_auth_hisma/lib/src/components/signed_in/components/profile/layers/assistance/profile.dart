enum PE {
  providerId,
  uid,
  displayName,
  email,
  photoURL,
  phoneNumber,
}

typedef ProfileMap = Map<PE, String>;

class Profile2 {
  Profile2({
    required this.profile,
    required this.providerProfiles,
  });
  ProfileMap profile;
  List<ProfileMap> providerProfiles;
}

class ProviderProfile {
  ProviderProfile({
    this.providerId,
    this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.phoneNumber,
  });
  String? providerId;
  String? uid;
  String? displayName;
  String? email;
  String? photoURL;
  String? phoneNumber;
}

class Profile {
  Profile({
    this.providerProfiles,
    this.uid,
    this.tenantId,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
  });
  String? uid;
  String? tenantId;
  String? displayName;
  String? email;
  String? phoneNumber;
  String? photoURL;

  List<ProviderProfile>? providerProfiles;
}
