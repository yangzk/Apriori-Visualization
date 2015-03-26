import controlP5.*;
 
public ControlP5 control;
public ControlWindow w;

void setParameters(){
  minWidthCoeff = 0.25;
  displayCartesian = true;
  speed = 1; // 1-500
 
  layerCoeff = 0.8;
  back_color = 255;
    
}


void makeControls(){
  control =  new ControlP5(this);
  
  w = control.addControlWindow("controlWindow", 10, 10, 350, 140);
  //w.hideCoordinates();
  w.setTitle("Drawing Parameters");
  
  int y = 0;
  
  control.addSlider("Speed",1,500, speed, 10,y += 10,256, 9).setWindow(w);
  
  
  control.addButton("Start").setWindow(w);
          
  
  control.setAutoInitialization(false);
}
