/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void win_draw1(GWinApplet appc, GWinData data) { //_CODE_:window1:827611:
  appc.background(230);
} //_CODE_:window1:827611:

public void startPause(GButton source, GEvent event) { //_CODE_:button_startPause:777700:
   
  println("button1 - GButton >> GEvent." + event + " @ " + millis());
     if(  event == GEvent.CLICKED){
       println("clicked");
       playNow = ! playNow;
   } 
  button_startPause.setEnabled(true); 
  button_lastFrame.setEnabled(true);
  button_nextFrame.setEnabled(true);
} //_CODE_:button_startPause:777700:

public void lastFrame(GButton source, GEvent event) { //_CODE_:button_lastFrame:985331:
  println("button_lastFrame - GButton >> GEvent." + event + " @ " + millis());
  i--;
  nodes[i].visited = false;
  
} //_CODE_:button_lastFrame:985331:

public void nextFrame(GButton source, GEvent event) { //_CODE_:button_nextFrame:332148:
  println("button_nextFrame - GButton >> GEvent." + event + " @ " + millis());
  
  nodes[i].visited = true;
  i++;
  
} //_CODE_:button_nextFrame:332148:

public void restart(GButton source, GEvent event) { //_CODE_:button_restart:541058:
  println("button_restart - GButton >> GEvent." + event + " @ " + millis());
  setup();
  /*
  for(int ii = 0; ii<i; ii++){
    nodes[ii].visited = false;
  }*/
  playNow = false;
  i=0;
} //_CODE_:button_restart:541058:

public void dropList_drawParents(GDropList source, GEvent event) { //_CODE_:drawParents:883009:
  println("drawParents - GDropList >> GEvent." + event + " @ " + millis());
  if(source.getSelectedIndex() == 0){
    drawTwoParents = true;
  }else{
    drawTwoParents = false;
  }
} //_CODE_:drawParents:883009:


public void dropList_drawCartesian(GDropList source, GEvent event) { //_CODE_:drawCartesian:883010:
  println("drawCartesian - GDropList >> GEvent." + event + " @ " + millis());
  if(source.getSelectedIndex() == 0){
    displaySpiral = true;
    button_startPause.setEnabled(false);
    button_lastFrame.setEnabled(false);
    button_nextFrame.setEnabled(false);
    playNow = false;
    textarea1.appendText("Drawing method changed to Spiral Mode. Please Restart. " );
  }else{
    displaySpiral = false;
    button_startPause.setEnabled(false);
    button_lastFrame.setEnabled(false);
    button_nextFrame.setEnabled(false);
    playNow = false;
    textarea1.appendText("Drawing method changed to Cartesian Mode. Please Restart. " );
  }
} //_CODE_:drawCartesian:883010:

public void slider_changeSpeed(GCustomSlider source, GEvent event) { //_CODE_:speed_slider:711720:
  println("speed_slider - GCustomSlider >> GEvent." + event + " @ " + millis());
  println("speed = " + source.getValueI());
  speed = source.getValueI();
  
} //_CODE_:speed_slider:711720:


public void textarea1_input(GTextArea source, GEvent event) { //_CODE_:textarea1:688922:
  println("textarea1 - GTextArea >> GEvent." + event + " @ " + millis());
 
} //_CODE_:textarea1:688922:


// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Sketch Window");
  window1 = new GWindow(this, "Control Panel", 0, 0, 300, 500, false, JAVA2D);
  window1.addDrawHandler(this, "win_draw1");
  
  button_startPause = new GButton(window1.papplet, 70, 180, 80, 30);
  button_startPause.setText(" > II ");
  //button_startPause.setFont(new Font("Monospaced", Font.PLAIN, 12));
  button_startPause.addEventHandler(this, "startPause");
  
  button_lastFrame = new GButton(window1.papplet, 30, 180, 30, 30);
  button_lastFrame.setText("<");
  button_lastFrame.addEventHandler(this, "lastFrame");
  
  button_nextFrame = new GButton(window1.papplet, 160, 180, 30, 30);
  button_nextFrame.setText(">");
  button_nextFrame.addEventHandler(this, "nextFrame");
  
  button_restart = new GButton(window1.papplet, 200, 180, 50, 30);
  button_restart.setText("Restart");
  button_restart.addEventHandler(this, "restart");
  /*
  drawParents = new GDropList(window1.papplet, 30, 20, 120, 60, 2);
  
  if(drawTwoParents == true){
  drawParents.setItems(loadStrings("list_883009"), 0);
  }else{
  drawParents.setItems(loadStrings("list_883009"), 1);
  }
  
  drawParents.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  drawParents.addEventHandler(this, "dropList_drawParents");*/
  
  
  label00 = new GLabel(window1.papplet, 0, 0, 300, 50);
  label00.setTextAlign(GAlign.CENTER, GAlign.TOP);
  label00.setText("AprioriViz");
  label00.setFont(new Font("Monospaced", Font.PLAIN, 25));
  label00.setOpaque(false);
  
  
  label0 = new GLabel(window1.papplet, 0, 35, 300, 50);
  label0.setTextAlign(GAlign.CENTER, GAlign.TOP);
  label0.setText("An Interactive Apriori Algorithm Visualzier \n Copyright © 2015 Zhenkai Yang @ KU Leuven");
  label0.setOpaque(false);
  
  label1 = new GLabel(window1.papplet, 25, 155, 80, 20);
  label1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label1.setText("Play Control");
  label1.setOpaque(false);
  
  label2 = new GLabel(window1.papplet, 25, 125, 100, 20);
  label2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label2.setText("Speed Control");
  label2.setOpaque(false);
  
  label3 = new GLabel(window1.papplet, 25, 90, 100, 20);
  label3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label3.setText("Draw Method");
  label3.setOpaque(false);
  
  drawCartesian = new GDropList(window1.papplet, 120, 90, 120, 60, 2); 
  
  if(displaySpiral == false){
    drawCartesian.setItems(loadStrings("list_883010"), 1);
  }else{
    drawCartesian.setItems(loadStrings("list_883010"), 0);
  }
  
  drawCartesian.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  drawCartesian.addEventHandler(this, "dropList_drawCartesian");
  
  speed_slider = new GCustomSlider(window1.papplet, 120, 120, 100, 30, "grey_blue");
  speed_slider.setShowValue(true);
  speed_slider.setShowLimits(true);
  speed_slider.setLimits(1, 1, 5);
  speed_slider.setNbrTicks(5);
  speed_slider.setStickToTicks(true);
  speed_slider.setShowTicks(true);
  speed_slider.setNumberFormat(G4P.INTEGER, 0);
  speed_slider.setOpaque(false);
  speed_slider.addEventHandler(this, "slider_changeSpeed");
  speed_slider.setValue(3);
  
  
  textarea1 = new GTextArea(window1.papplet, 5, 220, 290, 270, G4P.SCROLLBARS_VERTICAL_ONLY );
  textarea1.setOpaque(false);
  textarea1.addEventHandler(this, "textarea1_input"); 
  textarea1.setFont(new Font("", Font.PLAIN, 10));
  textarea1.setText(logText, 290);  
  textarea1.setTextEditEnabled(false);
   

}

// Variable declarations 
// autogenerated do not edit
GWindow window1;
GButton button_startPause; 
GButton button_lastFrame; 
GButton button_nextFrame; 
GButton button_restart; 
GDropList drawParents; 
GDropList drawCartesian;
GLabel label00;
GLabel label0;
GLabel label1; 
GLabel label2;
GLabel label3;
GCustomSlider speed_slider; 
GTextArea textarea1; 
String logText="";
