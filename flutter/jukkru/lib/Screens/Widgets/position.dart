class Positions{
   double _x1 = 0;
  //  int x2=0;
   double _y1 = 0;
  //  int y2=0;
  late double _pixelDistance;
  
  void setX1(double x){
   _x1=x;
  }

  void setY1(double y){
   _y1=y;
  }

  double getX1(){
    return _x1;
  }

  double getY1(){
    return _y1;
  }

  void setPixelDistance(double pixelDistance){
   _pixelDistance = pixelDistance;
  }

  double getPixelDistance(){
    return _pixelDistance;
  }
}