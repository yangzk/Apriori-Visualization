import g4p_controls.*;
 

import java.io.*;
import java.util.*;

import java.awt.Font;
import java.awt.*;

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
color nodeColor;

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


color white = color(255,255,255);
color blue = color(0,0,255,120);
color red = color(255,0,0,120);
color green = color(0,255,0);

void setup() {
   size(widthW,heightW); 
   
   frameRate(10);
   
   smooth();
   colorMode(RGB,255,255,255,255);
   //blendMode(ADD);
     
     //start GUI
     createGUI();
     
      
           
     playNow = false;
      
      minWidthCoeff = 0.25;
       
      speed = 1; // 1-7
   
      layerCoeff = 0.8;
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
    nodeTransp =  map(exp(-0.9*maxNodesRange+2.27),0,1,50,255);
    
    
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

  


void draw() {  
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

void drawUpToNow(){
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

void displayNodeInfo(Node thisNode){
   
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
     
