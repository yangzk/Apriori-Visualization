import g4p_controls.*;
 

import java.io.*;
import java.util.*;

JSONObject json;
JSONArray jnodes;


//things to control:
// 1. draw speed
// 2. pause draw
// 3. choose to draw all parents
// 4. start buttom

int widthW = 800;
int heightW = 600;

float minwidthW;

int nodeDelay;
int displayDelay;

//set the minimun width of the row
float minWidthCoeff ;


//craw crtesian or polar coordiantes
boolean displayCartesian;

//draw speed
int speed ;

 


//layer space to draw Bezier curve, 0<layerCoeff<1
float LayerSpace;
float layerCoeff ;


int nodeDepth = 0;
int startNode = 0;
int numNodes = 0;
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

void setup() {
     
     //! to start GUI
     createGUI();
     
     
     setParameters();
     nodeDelay =   500/speed;
     displayDelay =  1500/speed;
     //makeControls();
     
  
     float minwidthW =  widthW * minWidthCoeff;

  

  
  //noLoop();
  //astTime = millis();
   
  
  size(widthW,heightW);
   
   
  frameRate(60);
  
   

  json = loadJSONObject("/Users/zhenkai-Yang/Dropbox/Desktop/Thesis/apriori/test.json");

  nbrNodes = json.getInt("numNode");
  minSup = json.getFloat("minSup");

  println("number nodes = " + nbrNodes);
  println("min support = " + minSup);
  
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
         
         
         float numNodesRange = log(maxNumNodesLayer - 1);
         
         
         if(displayCartesian == true){
           LayerSpace = heightW*layerCoeff/(totDepth + 1)/3*2;
         }else{
           LayerSpace = heightW*layerCoeff/(totDepth + 1)/3/10;
         }
     





     
   for(Node node:nodes){
     
  
    //assign each node coordinates and its parents   
   
     node.layerSpace = LayerSpace;
     node.displayCartesian = displayCartesian;
     node.centroid = new PVector(widthW/2, heightW/2);
      
      
     if(displayCartesian == true){
       
        //display as horizontal tree, control draw range width
       if(node.numNodesLayer >1){
        float nodeWidth = map(log(node.numNodesLayer - 1), minNumNodesLayer, numNodesRange, minwidthW, widthW);
        node.x = nodeWidth*1.0/(node.numNodesLayer + 1)*(node.index + 1) + (widthW - nodeWidth)*1.0/2;
       }else{    
        node.x = widthW/2;
        //node.x = widthW*1.0/(node.numNodesLayer + 1)*(node.index + 1)
      }
        
        node.y = heightW*1.0/(totDepth + 1)*(node.depth + 1);
        
     }else{
        
       //display as polar tree        
        node.theta = 2*PI*1.0/(node.numNodesLayer )*(node.index );
        node.rad = min(heightW,widthW)*0.5/(totDepth +1 )*(node.depth +1 );
        node.x = node.rad*sin(node.theta) + widthW/2;
        node.y = -node.rad*cos(node.theta) + heightW/2;  
        
     }  
        
        if(node.freq >=0){
          node.r = sqrt(map(node.freq*node.freq,0,1,100,900));
        }
        
        
        
        
        String[] parents = node.parentid;           
            
        if (parents[0] != null ){

          for (int j=0; j < parents.length; j++){
            for(Node nodepar:nodes){
              if(nodepar.name.equals(parents[j])){
                node.addParent(nodepar);
              }
            }
            
           }
      }

   } 
  
}

  


void draw() {
  
      
     nodeDelay = (int) 500/speed;
     displayDelay = 1500/speed;
     //makeControls();
     
      
    ellipseMode(CENTER);
    
    //draw one node in each draw() loop, with a delay time nodeDelay, i is the current node index
    if ( i < nbrNodes  ){
      
       if(millis()-lastTime >nodeDelay){
       //draw all nodes and springs in the current depth, when finished, redraw un-prunned nodes 
       

        //node position is determined by all number of nodes (valid and unvalid) in the current depth

        //draw current node 
        nodes[i].display();
        nodes[i].visit();
        
        //nodes[i].expand();
        
         //draw parents of the current node
      
        ArrayList parents = nodes[i].getParents();
         
        
        for( Iterator parItr = parents.iterator(); parItr.hasNext();){
          Node parNode = (Node)parItr.next();
              
          Spring spring = new Spring(parNode, nodes[i]);
            
          spring.display();
           
          
        }
          
            
                   
        
      
      i++;
      lastTime = millis();
      nodeCountAll++;
      
      nodeCountValid = 0;
      //println("node " + i + " depth = " + currentDepth);
      
       }
      
      
      
      
      
      
    } else{
      
      
      drawFinished = true;
      
      background(back_color);
      for(Node tempNode:nodes){
        tempNode.display();
        ArrayList parents = tempNode.getParents();
        
        for( Iterator parItr = parents.iterator(); parItr.hasNext();){
          Node parNode = (Node)parItr.next();
              
          Spring spring = new Spring(parNode, tempNode);
            
          spring.display();
          
        }
        
      }
               
    }
    
    
     
    lastTime2 = 0;
    if ( millis() - lastTime2 > nodeDelay){
      noStroke();
      fill(back_color);
      rect(0,0,widthW,30);         
     }
   
    
    // select node closest to mouse position 
    Node minNode = nodes[0];
    float minDist = widthW;
    for(Node node:nodes){
      if(node.isWithin(mouseX, mouseY)){
        if(node.toDist(mouseX, mouseY) < minDist){
          minNode = node;
        }
      }  
    }
    
 
    
    
    // print the closest node if it is within node circle
    if(minNode.isWithin(mouseX, mouseY) && drawFinished == true ){
      
      String printFreq;
      if( minNode.freq == -1){
        printFreq = "lack subset in parents, pruned";
      }else if( minNode.freq < minSup){
        printFreq = minNode.freq +" < minSupport, pruned";
      }else{
        printFreq = String.valueOf(minNode.freq);
      }
      
      println("Mouse on node name = [" + minNode.name + "], depth = " + 
      minNode.depth + ", index = " + minNode.index + ", freq = " + printFreq);
           
      String s = "Node: " + minNode.name;    
      
      textSize(20);
      fill(0);
      text(s, 20, 20);
            
 
 
       
      //highlight all ancestors and springs   
      
      
      minNode.expand(); 
       
   
      lastTime2 = millis(); 
    }else if(minNode.isWithin(mouseX, mouseY) && minNode.visited == true){
      
      String printFreq;
      if( minNode.freq == -1){
        printFreq = "lack subset in parents, pruned";
      }else if( minNode.freq < minSup){
        printFreq = minNode.freq +" < minSupport, pruned";
      }else{
        printFreq = String.valueOf(minNode.freq);
      }
      
      println("Mouse on node name = [" + minNode.name + "], depth = " + 
      minNode.depth + ", index = " + minNode.index + ", freq = " + printFreq);
      
      String s = "Node: " + minNode.name;    
      
      textSize(20);
      fill(0);
      text(s, 20, 20);
    }
         
      
    
       
}
       
     
      
   
   
/* 
void mousePressed(){
    Node minNode = nodes[0];
    float minDist = widthW;
    for(Node node:nodes){
      if(node.isWithin(mouseX, mouseY)){
        if(node.toDist(mouseX, mouseY) < minDist){
          minNode = node;
        }
      }  
    }
    
    
    // print the closest node if it is within node circle
    if(minNode.isWithin(mouseX, mouseY) && minNode.visited == true){
      
      String printFreq;
      if( minNode.freq == -1){
        printFreq = "lack subset in parents, pruned";
      }else if( minNode.freq < minSup){
        printFreq = minNode.freq +" < minSupport, pruned";
      }else{
        printFreq = String.valueOf(minNode.freq);
      }
      
      println("Mouse on node name = [" + minNode.name + "], depth = " + 
      minNode.depth + ", index = " + minNode.index + ", freq = " + printFreq);
           
      String s = "Node: " + minNode.name;    
      
      textSize(20);
      fill(0);
      text(s, 20, 20);
            
 
 
       
      //highlight all ancestors and springs   
      
      minNode.expand(); 
           
           
       
      
   
      lastTime2 = millis(); 
    }
}   


void mouseMoved(){
if(millis()-lastTime3 <displayDelay){
    Node minNode = nodes[0];
    float minDist = widthW;
    for(Node node:nodes){
      if(node.isWithin(mouseX, mouseY)){
        if(node.toDist(mouseX, mouseY) < minDist){
          minNode = node;
        }
      }  
    }
    
    
    // print the closest node if it is within node circle
    if(minNode.isWithin(mouseX, mouseY) && minNode.visited == true){
      
      String printFreq;
      if( minNode.freq == -1){
        printFreq = "lack subset in parents, pruned";
      }else if( minNode.freq < minSup){
        printFreq = minNode.freq +" < minSupport, pruned";
      }else{
        printFreq = String.valueOf(minNode.freq);
      }
      
      println("Mouse on node name = [" + minNode.name + "], depth = " + 
      minNode.depth + ", index = " + minNode.index + ", freq = " + printFreq);
           
      String s = "Node: " + minNode.name;    
      
      textSize(20);
      fill(0);
      text(s, 20, 20);
            
 
 
       
      //highlight all ancestors and springs   
      
      //minNode.expand(); 
           
           
       
      
   
      lastTime3 = millis(); 
    }
    
}
}
 
  */
