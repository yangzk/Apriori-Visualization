import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import g4p_controls.*; 
import java.io.*; 
import java.util.*; 
import java.awt.Font; 
import java.awt.*; 

import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AprioriViz extends PApplet {


 







JSONObject json;
JSONArray jnodes;


//things to control:
// 1. draw speed
// 2. pause draw
// 3. choose to draw all parents
// 4. start buttom

int widthW = 600;
int heightW = 600;

float minwidthW;

int nodeDelay;
int displayDelay;

//set the minimun width of the row
float minWidthCoeff ;


float nodeTransp = 50;
int nodeColor;

//craw crtesian or polar coordiantes
boolean displaySpiral;

boolean drawTwoParents;

//draw speed
int speed ;

boolean playNow ;


//layer space to draw Bezier curve, 0<layerCoeff<1
float LayerSpace;
float layerCoeff ;


int nodeDepth = 0;
int startNode = 0;
int numNodes = 0;
int numItems = 0;
int totDepth = 0;
int back_color;
float minSup;


int nbrNodes;
long lastTime = 0;
long lastTime2 = 0;
long lastTime3 = 0;

Node[] nodes;  
Spring spring;
  
int i=0; 
int currentDepth = 0;
//int tempDepth = 0;
  
int nodeCountAll = 0;
int nodeCountValid = 0; 
int tempDepth = 0;

boolean drawFinished = false;
Node mouseOnNode;

int maxNumNodesLayer = 0;
int minNumNodesLayer = Integer.MAX_VALUE;

ArrayList<Node> nodeList = new ArrayList<Node>();


int white = color(255,255,255);
int blue = color(0,0,255,120);
int red = color(255,0,0,120);
int green = color(0,255,0);

public void setup() {
   size(widthW,heightW); 
   
   frameRate(10);
   
   smooth();
   colorMode(RGB,255,255,255,255);
   //blendMode(ADD);
     
     //start GUI
     createGUI();
     
      
           
     playNow = false;
      
      minWidthCoeff = 0.25f;
       
      speed = 1; // 1-7
   
      layerCoeff = 0.8f;
      back_color = 255;
  
     nodeDelay = 500/(speed*speed*speed);
     displayDelay = 1500/(speed*speed*speed);
     //nodeDelay = 500/speed;
     //displayDelay = 1500/speed;
      
     
  
     float minwidthW =  widthW * minWidthCoeff;

  

  
  
  //astTime = millis();
   
  
 
  
  
   

  json = loadJSONObject("data/test.json");

  nbrNodes = json.getInt("numNodes");
  minSup = json.getFloat("minSup");
  numItems = json.getInt("numItems");

  //println("number nodes = " + nbrNodes);
  //println("min support = " + minSup);
  
  jnodes = json.getJSONArray("Node");
  
    String id;
    String name;
    float freq;
        
    lastTime = millis();
    lastTime2 = millis();
    
    background(back_color);
    nodes = new Node[nbrNodes];
     
     
    // assign nodes and strings 
    for (int i = 0; i< nbrNodes; i++){
      
      String[] parentid = new String[10];
                 
      JSONObject jnode = jnodes.getJSONObject(i); 
      id = jnode.getString("id");
      name = jnode.getString("name");
      freq = jnode.getFloat("freq");
             
      JSONArray parent = jnode.getJSONArray("parentid"); 
      
      if (!parent.isNull(0) ){
        for (int j = 0; j < parent.size(); j++){
            parentid[j] = parent.getString(j);     
        }   
      }
         
      nodes[i] = new Node(id,name,freq,parentid);
      
      
      totDepth = nodes[i].depth +1;
       
       
      //start with 1, assign numNodeslayer
       
        
        if(nodes[i].depth == nodeDepth ){
          numNodes ++;
          for(int j = startNode; j<= i; j++){
            nodes[j].numNodesInLayer(numNodes);
          }          
        }else {
          startNode = i;
          nodeDepth = nodes[i].depth;
          numNodes = 1;
          nodes[i].numNodesInLayer(numNodes);
        }
        
        
        if(nodes[i].numNodesLayer > maxNumNodesLayer){
          maxNumNodesLayer = nodes[i].numNodesLayer;
        }
         
        if(nodes[i].numNodesLayer < minNumNodesLayer && nodes[i].numNodesLayer > 1 ){
          minNumNodesLayer = nodes[i].numNodesLayer;
        }
        
          
      }
         
         float minNodesRange = log(minNumNodesLayer - 1); 
         float maxNodesRange = log(maxNumNodesLayer - 1);        
         
         if(displaySpiral == false){
           LayerSpace = heightW*layerCoeff/(totDepth + 1)/3*2;
         }else{
           LayerSpace = heightW*layerCoeff/(totDepth + 1)/3/10;
         }
     
    //println("maxNodesRange = " + maxNodesRange); 
    nodeTransp =  map(exp(-0.9f*maxNodesRange+2.27f),0,1,50,255);
    
    
   //println("trans = " + nodeTransp);
     
   for(Node node:nodes){
     
    node.assignColor();
    //assign each node coordinates and its parents   
   
     node.layerSpace = LayerSpace;
     node.displaySpiral = displaySpiral;
     node.centroid = new PVector(widthW/2, heightW/2);
      
     
     //println("transparant = " + nodeTransp);
      
     if(displaySpiral == false){
       
        //display as horizontal tree, control draw range width
       if(node.numNodesLayer >1){
        float nodeWidth = map(log(node.numNodesLayer - 1), minNodesRange, maxNodesRange, minwidthW, widthW);
        node.x = nodeWidth*1.0f/(node.numNodesLayer + 1)*(node.index + 1) + (widthW - nodeWidth)*1.0f/2;
       }else{    
        node.x = widthW/2;
        //node.x = widthW*1.0/(node.numNodesLayer + 1)*(node.index + 1)
      }
        
        node.y = heightW*1.0f/(totDepth + 1)*(node.depth + 1);
        
     }else{
        
       //display as polar tree        
        node.theta = 2*PI*1.0f/(node.numNodesLayer )*(node.index );
        node.rad = min(heightW,widthW)*0.5f/(totDepth +1 )*(node.depth +1 );
        node.x = node.rad*sin(node.theta) + widthW/2;
        node.y = -node.rad*cos(node.theta) + heightW/2;  
        
     }  
        
        //map node R=10~30
        if(node.freq >=0){
          node.r = sqrt(map(node.freq*node.freq,0,1,100,900));
        }
        
        
        
        
        String[] parents = node.parentid;           
            
        if (parents[0] != null ){
          int loopSize = parents.length;
          if(drawTwoParents == true){
            loopSize = 2;
          }
         
          for (int j=0; j < loopSize; j++){
            for(Node nodepar:nodes){
              if(nodepar.name.equals(parents[j])){
                node.addParent(nodepar);
              }
            }           
           }
                     
      }

   } 
 //textarea1.appendText("Done. Ready to draw. ");
 //textarea1.setText(" ");
 textarea1.setText("Input configuration: " + numItems + " items, " + nbrNodes + " nodes, minSup = " + minSup +". \n" );
 textarea1.appendText("Ready to draw.");
 
 button_lastFrame.setEnabled(false);
 button_nextFrame.setEnabled(false);
  

}

  


public void draw() {  
    frame.setTitle("Visualization Panel");
      
     nodeDelay =  500/speed;
     displayDelay = 1500/speed;
     nodeDelay = 500/(speed*speed);
     displayDelay = 1500/(speed*speed);
     //makeControls();
     
      
    ellipseMode(CENTER);
    
    //draw node one by one, i is the current node index
    if ( i < nbrNodes  ){
      
       
       lastTime3 = millis();
       //when drawing is ongoing and time exceeds a loop delay, draw a node 
       //this if() only runs only one iterate
       
       if(millis()-lastTime >5 *nodeDelay && playNow == true){
         button_restart.setEnabled(false);
         
        //get all parents of the current node, display parents and spring 
        //JOIN STEP: 1) highlight the two direct parents
        // 2) draw directions from parents to child(the current node)
        
        if(nodes[i].depth>1){
           
          ArrayList parents = nodes[i].getParents();
                                  
          for( Iterator parItr = parents.iterator(); parItr.hasNext();){
            Node parNode = (Node)parItr.next();             
            Spring spring = new Spring(parNode, nodes[i]);         
            spring.display();                 
          }
        }
         
        //nodes[i].drawCircle();
        
         
        //PRUNE STEP: 1) after depth>1, get all subsets (by highlighting 
        //all parents)
        //2) if(freq==-1),draw blue node
        //3) if(freq<minSup),draw red node
        //if(freq>minSup), draw black
        nodes[i].display();
        nodes[i].visit();
        
        
        //textarea1.
        if(nodes[i].depth<2){
          appendText("[JOIN] Creating node [" + nodes[i].name + "]");
          /*
          if(nodes[i].freq < minSup){
            appendText("[PRUNE] a posteriori pruning node [" + nodes[i].name + "], freq=" + nodes[i].freq + "< minSup" );
          }*/
      
        }
 

         
      
      i++;
      lastTime = millis();
      nodeCountAll++;
      
      nodeCountValid = 0;
      //println("node " + i + " depth = " + currentDepth);
      
       }else{
         //when draw is paused, draw everything up to now
         //
         
         if(playNow == false){           
           button_restart.setEnabled(true);
           
           Node minNode = getMinNode();
    
     
    // print the closest node if it is within node circle
    if(minNode.isWithin(mouseX, mouseY) && minNode.visited == true ){
      

       displayNodeInfo(minNode);
            
       //highlight all ancestors and springs   
          
      minNode.expand(); 
      minNode.highlight();
          
       
    }
           
           
         }
         
         
         drawUpToNow();
         
         
           
         if(i>0){
 
           
           if(millis()-lastTime > 4* nodeDelay){
               //4. if prune happens, draw a highlight/flash
             //textarea1.appendText("Pruning node [" + nodes[i].name + "] \n" );
             //nodes[i].flash();
             
              
 
             nodes[i].highlight();
             
    
             nodes[i].expandParents();
             nodes[i].drawInfoOnNode();
             
               
             if(nodes[i].freq == -1){
               //textarea1.
               appendText("[PRUNE] a priori pruning node [" + nodes[i].name + "]");
             }else if(nodes[i].freq<minSup){
               //textarea1.
               appendText("[PRUNE] a posteriori pruning node [" + nodes[i].name + "], freq=" + nodes[i].freq + "< minSup" );
             }else{
               //textarea1.appendText("[PRUNE] node [" + nodes[i].name + "] is not pruned. \n");
               //appendText("[PRUNE] node [" + nodes[i].name + "] is not pruned.");
             }  
             
             
             
           }else if(millis()-lastTime >3*nodeDelay){
            //3. expand all its subset parents
            //nodes[i].highlightTwoParents();
            if(nodes[i].depth>1){
              //textarea1.
              appendText("[PRUNE] Geting node [" + nodes[i].name + "]'s subsets");
            } 
            nodes[i].drawCircle();
            nodes[i].expandParents();
            nodes[i].drawInfoOnNode();
             
           
           }else if(millis()-lastTime >2* nodeDelay){
             //2. draw unknown node and two strings
             nodes[i].highlightTwoParents();
             nodes[i].highlightParSpring();
             nodes[i].drawCircle();
             nodes[i].drawInfoOnNode();            
             if(nodes[i].depth>1){
               //textarea1.
               appendText("[JOIN] Creating node [" + nodes[i].name + "]");
             } 
                }else if(millis()-lastTime >1* nodeDelay){
                   //1. highlight the node's two parents
              
                    nodes[i].highlightTwoParents();
           
                          
           }
           
         }
       }
      
      
      
      
      
      
    } else{
      
      //draw has finished
      drawFinished = true;
      playNow = false;
      button_restart.setEnabled(true);
      
      drawUpToNow();
               
    }
    
    
     
    lastTime2 = 0;
     
    
    // select node closest to mouse position 
    Node minNode = getMinNode();
    
     
    // print the closest node if it is within node circle
    if(minNode.isWithin(mouseX, mouseY) && minNode.visited == true && drawFinished == true){
      

       displayNodeInfo(minNode);
            
       //highlight all ancestors and springs   
          
      minNode.expand(); 
      minNode.highlight();
          
      lastTime2 = millis(); 
    }
 
 
       
}

public void drawUpToNow(){
      background(back_color);
      for(Node tempNode:nodes){
        if(tempNode.visited == true && tempNode.visited == true){
        tempNode.display();
        ArrayList parents = tempNode.getParents();
        
 
        
        for( Iterator parItr = parents.iterator(); parItr.hasNext();){
          Node parNode = (Node)parItr.next();
              
          Spring spring = new Spring(parNode, tempNode);
            
          spring.display();
          
        }
        }
      }
}

public void displayNodeInfo(Node thisNode){
   
       String printFreq;
      if( thisNode.freq == -1){
        printFreq = "a priori pruned";
      }else if( thisNode.freq < minSup){
        printFreq = thisNode.freq +" < minSupport, a posteiori pruned";
      }else{
        printFreq = String.valueOf(thisNode.freq);
      }
       
       
  //textarea1.
  appendText("Mouse on node [" + thisNode.name + "], freq = " + printFreq + " ");

} 

public Node getMinNode(){
    Node minNode = nodes[0];
    float minDist = widthW;
    for(Node node:nodes){
      if(node.isWithin(mouseX, mouseY)){
        if(node.toDist(mouseX, mouseY) < minDist){
          minNode = node;
          continue;
        }
      } 
    }
    return minNode;
}


public void appendText(String text){
 GTextArray = textarea1.getTextAsArray();
 if( ! text.equals(GTextArray[GTextArray.length-1]) ){
   textarea1.appendText(text);
 }
}
     
public  class Node{
     
     
  
  
    String id;
    int depth;
    int index;
    String name;
    float freq;
    String[] parentid; 
    float x,y,px,py;
       
    String[] idSplit;
    String[] nameSplit;
    int xspeed = 1;
    int yspeed = 1;
    float r;
    
    int numNodesLayer = 0;
    
    float layerSpace;
     
    ArrayList parents = new ArrayList();
    
    
    boolean visited;
    boolean displaySpiral;
    
    //theta and radius in polar coordiante system
    float theta;
    float rad;
    PVector centroid = new PVector(0,0);
    
    int fillColor;
    
    
    
    Node(String id, String name, float freq, String[] parentid)
    {
      this.id = id;
      this.name = name;
      this.freq = (float) freq;
      this.parentid = parentid;
      this.r = 10;
      
      this.visited = false;
     
      this.idSplit = id.split(" ");
      
      
       
      this.depth = Integer.parseInt(this.idSplit[0]);
      this.index = Integer.parseInt(this.idSplit[1]);
        
      this.nameSplit = name.split(" ");
      
      this.x = 100.0f + 100.0f*index;
      this.y = 100.0f + 100.0f*depth;
      
      this.layerSpace = layerSpace;
      this.theta = theta;
      this.rad = rad;
      this.centroid = centroid;
      
      if (this.freq >= minSup ){
        
        //node with freq > minSup --> black
        
        //this.fillColor = nodeColor;
        this.fillColor = nodeColor;
                
      }else if (this.freq >= 0){
        
         //prune due to low support --> red
        this.fillColor = color(255,0,0,255); 
                 
      }else if (this.freq == -1){
        
        //prune due to absence of subset --> blue       
        this.fillColor = color(0,0,255,255);  
        
       }
    }
    
    public void assignColor(){
      if (this.freq >= minSup ){
        
        //node with freq > minSup --> black
                
        this.fillColor = color(0,0,0,nodeTransp);
                
      }else if (this.freq >= 0){
        
         //prune due to low support --> red
        this.fillColor = color(255,0,0,map(nodeTransp,0,255,120,255)); 
                 
      }else if (this.freq == -1){
        
        //prune due to absence of subset --> blue       
        this.fillColor = color(0,0,255,map(nodeTransp,0,255,120,255));  
        
       }
      
    }
    
    public int getDepth(){
      return depth;
    }
    
    public int getIndex(){
      return index;
    }
    
    public float x(){
      return this.x;
    }
    
    public float y(){
      return this.y;
    }
    
    public float pr(){
      return this.r;
    }
    
    public boolean isWithin(float px, float py){
      float dx = px - this.x;
      float dy = py - this.y;
      return sqrt(dx*dx + dy*dy) <= this.r *2.0f;
    }
    
    public float toDist(float px, float py){
      float dx = px - this.x;
      float dy = py - this.y;
      return sqrt(dx*dx + dy*dy) ;
    }
    
    public void numNodesInLayer(int n){
      this.numNodesLayer = n;
    }
      
    
 
    
    public void display(){
      
      noStroke();
      fill(this.fillColor);
       
      ellipse(this.x, this.y, this.r, this.r);
     
    }
    
    public boolean isFreq(){
      if (this.freq >= minSup ){
        return true;
      }else{
        return false;
      }
    }
    
    public void drawCircle(){
      
      noStroke();
       
       
      fill(green);
      ellipse(this.x, this.y, 20, 20);
       
      
      fill(white);
      ellipse(this.x, this.y, 15, 15);
       
    }
    
    
    public void highlight(){
      
      float newr = this.r  ;
      noStroke();
      
      stroke(green);
      strokeWeight(3);
      
      fill(this.fillColor);
      ellipse(this.x, this.y, newr+3, newr+3);
      
       
      
      /*
      if (this.freq >= minSup ){
        
        //node with freq > minSup --> black
        fill(0,0,0,120);
        ellipse(this.x, this.y, newr, newr);
        
      }else if (this.freq >= 0){
        
         //prune due to low support --> red
        fill(255,0,0,120); 
        ellipse(this.x, this.y, newr, newr);
        
      }else if (this.freq == -1){
        
        //prune due to absence of subset --> blue       
        fill(0,0,255,120);  
        ellipse(this.x, this.y, newr, newr);
        
      }*/
    }
    
    public ArrayList getParents(){
      return this.parents;
    }
    
    /*
    public ArrayList getParents(int npars){
      ArrayList tempParents = new ArrayList<Node>();
      if(npars>=1){
      for(int n=0; n<npars; n++){
        tempParents.add(parents.get(n));
      }} else{
        return this.parents;
      }
             
      return tempParents;
    }*/
    
    public void addParent(Node parent){
      this.parents.add(parent);
    }
    
    public void visit(){
      this.visited = true;
    }
    
    
    public void expand(){
      
      this.drawInfoOnNode();
      
      float LayerSpace  = this.layerSpace;
      
      //this.highlight();
      
      Iterator<Node> parItr = this.parents.iterator();
            
      while(parItr.hasNext()){
        
        Node parNode = (Node)parItr.next();
        parNode.highlight();
              
        Spring spring = new Spring(parNode, this);        
            
        spring.highlight();
        
        parNode.expand(); 
                 
      }
            
    }
    
    
    public void flash(){
      float newr = this.r;
       
      if(this.freq == -1){
        //flash this node and parent node which is pruned
        //fill(255,255,255);  
        //ellipse(this.x, this.y, newr, newr);
        noStroke();
        fill(0,0,255,120);  
        ellipse(this.x, this.y, newr, newr);
        fill(255,255,255);  
        ellipse(this.x, this.y, newr, newr);
 
        
        Iterator<Node> parItr = this.parents.iterator();
            
        while(parItr.hasNext()){        
          Node parNode = (Node)parItr.next();
          parNode.flash();                 
        }
                
      }else if( this.freq < minSup){
        //flash this node
        //fill(255,255,255); 
        //ellipse(this.x, this.y, newr, newr);
        noStroke();
        fill(255,0,0,120); 
        ellipse(this.x, this.y, newr, newr);
        fill(255,255,255); 
        ellipse(this.x, this.y, newr, newr);
 
      }
    }
    
    public void expandParents(){
      
      //this.drawInfoOnNode();
      
      float LayerSpace  = this.layerSpace;
      
      //this.highlight();
      
      Iterator<Node> parItr = this.parents.iterator();
            
      while(parItr.hasNext()){
        
        Node parNode = (Node)parItr.next();
        parNode.highlight();
        parNode.drawInfoOnNode();
              
        Spring spring = new Spring(parNode, this);        
            
        spring.highlight();
        
        //parNode.expand(); 
                 
      }
            
    }
    
    public void highlightParSpring(){
      Iterator<Node> parItr = this.parents.iterator();
      int itr=0;
            
      while(parItr.hasNext() && itr<2){
        
        Node parNode = (Node)parItr.next();
        
        parNode.drawInfoOnNode();
              
        Spring spring = new Spring(parNode, this);        
            
        spring.highlight();
        
        itr++;                 
      }      
    }
    
    public void highlightTwoParents(){
      
      Iterator<Node> parItr = this.parents.iterator();
      int itr=0;
            
      while(parItr.hasNext() && itr<2){
        
        Node parNode = (Node)parItr.next();
        
        parNode.drawInfoOnNode();
        parNode.highlight();
                      
        itr++; 
                 
      }
      
    }
    
    
    public void drawInfoOnNode(){
          
      
      textSize(10);
      fill(0);
      text(this.name, this.x-5, this.y-10);
    }
    
    
    
    
    
  }
public class Spring{
  
  Node node1 ; //parent node
  Node node2 ; // child node
  int steps = 10;
  
  Spring(Node node1, Node node2){
    this.node1 = node1;
    this.node2 = node2;
  }
  
 
  
  public void highlight(){
    
    float LayerSpace  = node1.layerSpace;
    stroke(0,255,0,150);
    strokeWeight(1);
    noFill();
    if(node1.displaySpiral == false){ 
      
      
      bezier(node1.x, node1.y, node1.x, node1.y + LayerSpace,  
      node2.x, node2.y - LayerSpace, node2.x, node2.y);
      
      
      
    }else{


           
      PVector[] pv = new PVector[steps];  
       
      PVector centroid = node1.centroid;
      
      float Dtheta = node2.theta - node1.theta;
      float Drad = node2.rad - node1.rad;
      float tSpeed = Dtheta *1.0f /steps;
      float rSpeed = Drad * 1.0f/steps;
      
       
      for(int t=0; t<steps; t++){
        pv[t] = new PVector(0.0f, 0.0f);
         
         pv[t].set( centroid.x + (node1.rad + rSpeed*t) * sin(node1.theta + tSpeed*t),
                    centroid.y - (node1.rad + rSpeed*t) * cos(node1.theta + tSpeed*t) );
         
      }
      
        noFill();
        beginShape();    
       
        
        curveVertex(pv[0].x, pv[0].y); // the first control point
        
        for(int i=0; i<steps; i++){
          curveVertex(pv[i].x, pv[i].y); // is also the start point of curve         
        }
        
   
        curveVertex(node2.x, node2.y); // the last point of curve
        curveVertex(node2.x, node2.y); // is also the last control point
        endShape();
        
        
    
    }
  }
  
  public void display(){
    float LayerSpace  = node1.layerSpace;
    stroke(0,0,0,nodeTransp*0.5f);
    strokeWeight(1);
    noFill();
    
    if(node1.freq == -1){
      stroke(0,0,255,map(nodeTransp,0,255,120,255));
    }else if(node1.freq < minSup){
      stroke(255,0,0,map(nodeTransp,0,255,120,255));
    }
   
   //draw in cartesian mode 
    if(node1.displaySpiral == false){   
      bezier(node1.x, node1.y, node1.x, node1.y + LayerSpace,  
      node2.x, node2.y - LayerSpace, node2.x, node2.y);
    }else{
      
            
      PVector[] pv = new PVector[steps];  
       
      PVector centroid = node1.centroid;
      
      float Dtheta = node2.theta - node1.theta;
      float Drad = node2.rad - node1.rad;
      float tSpeed = Dtheta *1.0f /steps;
      float rSpeed = Drad * 1.0f/steps;
      
       
      for(int t=0; t<steps; t++){
        pv[t] = new PVector(0.0f, 0.0f);
         
         pv[t].set( centroid.x + (node1.rad + rSpeed*t) * sin(node1.theta + tSpeed*t),
                    centroid.y - (node1.rad + rSpeed*t) * cos(node1.theta + tSpeed*t) );
         
      }
      
        noFill();
        beginShape();    
       
        
        curveVertex(pv[0].x, pv[0].y); // the first control point
        
        for(int i=0; i<steps; i++){
          curveVertex(pv[i].x, pv[i].y); // is also the start point of curve         
        }
        
   
        curveVertex(node2.x, node2.y); // the last point of curve
        curveVertex(node2.x, node2.y); // is also the last control point
        endShape();
  
    
    }
    
  }
  
}
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
   
  //println("button1 - GButton >> GEvent." + event + " @ " + millis());
     if(  event == GEvent.CLICKED){
       //println("clicked");
       if(playNow == true){
         appendText("======Paused======");
       }else{
         appendText("======Start======");
       }
       
       playNow = ! playNow;
       
       
     
   } 
  button_startPause.setEnabled(true); 
  button_lastFrame.setEnabled(true);
  button_nextFrame.setEnabled(true);
} //_CODE_:button_startPause:777700:

public void lastFrame(GButton source, GEvent event) { //_CODE_:button_lastFrame:985331:
  //println("button_lastFrame - GButton >> GEvent." + event + " @ " + millis());
  i--;
  nodes[i].visited = false;
  
} //_CODE_:button_lastFrame:985331:

public void nextFrame(GButton source, GEvent event) { //_CODE_:button_nextFrame:332148:
  //println("button_nextFrame - GButton >> GEvent." + event + " @ " + millis());
  
  nodes[i].visited = true;
  i++;
  
} //_CODE_:button_nextFrame:332148:

public void restart(GButton source, GEvent event) { //_CODE_:button_restart:541058:
  //println("button_restart - GButton >> GEvent." + event + " @ " + millis());
  setup();
  /*
  for(int ii = 0; ii<i; ii++){
    nodes[ii].visited = false;
  }*/
  playNow = false;
  i=0;
} //_CODE_:button_restart:541058:

public void dropList_drawParents(GDropList source, GEvent event) { //_CODE_:drawParents:883009:
  //println("drawParents - GDropList >> GEvent." + event + " @ " + millis());
  if(source.getSelectedIndex() == 0){
    drawTwoParents = true;
  }else{
    drawTwoParents = false;
  }
} //_CODE_:drawParents:883009:


public void dropList_drawCartesian(GDropList source, GEvent event) { //_CODE_:drawCartesian:883010:
  //println("drawCartesian - GDropList >> GEvent." + event + " @ " + millis());
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
  //println("speed_slider - GCustomSlider >> GEvent." + event + " @ " + millis());
  //println("speed = " + source.getValueI());
  speed = source.getValueI();
  
} //_CODE_:speed_slider:711720:


public void textarea1_input(GTextArea source, GEvent event) { //_CODE_:textarea1:688922:
  //println("textarea1 - GTextArea >> GEvent." + event + " @ " + millis());
 
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
  label0.setText("An Interactive Apriori Algorithm Visualzier \n Copyright \u00a9 2015 Zhenkai Yang @ KU Leuven");
  label0.setOpaque(false);
  
  label1 = new GLabel(window1.papplet, 15, 155, 80, 20);
  label1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label1.setText("Play Control");
  label1.setOpaque(false);
  
  label2 = new GLabel(window1.papplet, 15, 125, 100, 20);
  label2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label2.setText("Speed Control");
  label2.setOpaque(false);
  
  label3 = new GLabel(window1.papplet, 15, 90, 100, 20);
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
  
  speed_slider = new GCustomSlider(window1.papplet, 120, 120, 120, 30, "grey_blue");
  speed_slider.setShowValue(true);
  speed_slider.setShowLimits(true);
  speed_slider.setLimits(1, 1, 7);
  speed_slider.setNbrTicks(7);
  speed_slider.setStickToTicks(true);
  speed_slider.setShowTicks(true);
  speed_slider.setNumberFormat(G4P.INTEGER, 0);
  speed_slider.setOpaque(false);
  speed_slider.addEventHandler(this, "slider_changeSpeed");
  speed_slider.setValue(1);
  
  
  textarea1 = new GTextArea(window1.papplet, 10, 220, 280, 270, G4P.SCROLLBARS_VERTICAL_ONLY );
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

String[] GTextArray;
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "AprioriViz" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
