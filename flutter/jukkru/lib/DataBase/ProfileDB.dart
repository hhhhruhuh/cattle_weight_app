  class ProfileDB{
  late int cattleNumber;
  late String cattleName;
  late String gender;
  late String specise;
  late String img;
  

  ProfileDB(this.cattleNumber,this.cattleName,this.gender,this.specise,this.img);

  // Setter
  void setCattleNumber(int cattleNumber){
    this.cattleNumber = cattleNumber;
  }

  void setCattleName(String cattlName){
    cattleName = cattlName;
  }

  void setGender(String gender){
    this.gender = gender;
  }

  void setSpecise(String specise){
    this.specise = specise;
  }

  // Getter
  int getCattleNumber(){
    return cattleNumber;
  }

  String getCattleName(){
    return cattleName;
  }

  String getGender(){
    return gender;
  }
  String getSpecise(){
    return specise;
  }
   String getImg(){
    return img;
  }

  void showdata(){
    print("ProfileDB");
    print("Cattle number : $cattleNumber");
    print("Cattle name : $cattleName");
    print("Gender : $gender");
    print("Specise : $specise");

  }

}