JSONObject json;
JSONArray jnodes;

int widthW = 1200;
int heightW = 500;
int nodeDelay = 500;
int layerDelay = 3000;

 

int nbrNodes;
long lastTime = 0;
long lastTime2 = 0;

void setup() {
  
  //noLoop();
  //astTime = millis();
  
  size(widthW,heightW);

  json = loadJSONObject("test.json");

  nbrNodes = json.getInt("NumNode");

  println("number node=" + nbrNodes);
  
  jnodes = json.getJSONArray("Node");
  
    String id;
    String name;
    float freq;
    
    
    lastTime = millis();
    lastTime2 = millis();
    
    background(200);
    nodes = new Node[nbrNodes];
     
     
    // assign nodes and strings 
    for (int i = 0; i< nbrNodes; i++){
      
      String[] parentid = new String[2];
                 
      JSONObject jnode = jnodes.getJSONObject(i); 
      id = jnode.getString("id");
      name = jnode.getString("name");
      freq = jnode.getFloat("freq");
             
      JSONArray parent = jnode.getJSONArray("parentid"); 
      
      if (!parent.isNull(0) && !parent.isNull(1)){
        for (int j = 0; j < parent.size(); j++){
            parentid[j] = parent.getString(j);     
        }   
      }
         
      nodes[i] = new Node(id,name,freq,parentid);
         
    }   
       
  
}

  


   
  
  
  
  
  

  Node[] nodes;  
  Spring spring;
  
  int i=0; 
  int currentDepth = 0;
  int tempDepth = 0;
  
  int nodeCountAll = 0;
  int nodeCountValid = 0; 
  
void draw() {
     
    ellipseMode(CENTER);
    
    //draw one node in each draw() loop, with a delay time nodeDelay, i is the current node index
    if ( i < nbrNodes && (millis()-lastTime >nodeDelay)  ){
      
      
      //draw all nodes and springs in the current depth, when finished, redraw un-prunned nodes 
      if(nodes[i].depth == currentDepth){ 
      
      //node position is determined by all number of nodes (valid and unvalid) in the current depth
      nodes[i].x = (nodeCountAll+1.0)/(nodeCountAll+2.0)*widthW;
      
      //draw current node 
      nodes[i].display();
      
      //move node to some position...
      
      
       
       
       
      //get parents of the current node
      String[] parents = nodes[i].parentid;
            
      if (parents[0] != null ){

        for (int j=0; j < parents.length; j++){
          
          //draw spring lines between child and parents
          for (int k=0; k < nbrNodes; k++){
            
            if(nodes[k].id.equals(parents[j])   ){
               
              Spring spring = new Spring(nodes[i], nodes[k]);
              
              //draw spring 
              spring.display();
              
            }
          
          }
        }
           
      }//draw done
      
      i++;
      lastTime = millis();
      nodeCountAll++;
      
      println("node " + i + " depth = " + currentDepth);
      
    }else{
      
        
      //when the nodes in the current depth is finished, we will prune
      //some nodes and redraw all VALID nodes and springs up to now
      
      nodeCountAll = 0;
      
      //redraw after time layerDelay
      if( millis()-lastTime >layerDelay ){
        
        //clear background and redraw
        clear();
        background(200);
        
        //draw nodes up to now
        for (int ii=0; ii < i; ii++){
           
            
           //only draw valid nodes  
           if(nodes[ii].depth == tempDepth ){
             
             if (nodes[ii].freq > 0){
             
             nodes[ii].x = (nodeCountValid+1.0)/(nodeCountValid+2.0)*widthW;
             nodes[ii].display();
             //move node to some position...
             
             
             
            
             String[] parents = nodes[ii].parentid;
            
             if (parents[0] != null ){
     
               for (int jj=0; jj < parents.length; jj++){
          
                 //search for its parents and create spring between them
                 for (int kk=0; kk < nbrNodes; kk++){
            
                   if(nodes[kk].id.equals(parents[jj])   ){
               
              Spring spring = new Spring(nodes[ii], nodes[kk]);
              //draw spring 
              spring.display();
              
            }
          
          }
        }
           
      }
            
        }
        nodeCountValid++; 
        
      }else   {
        tempDepth =  nodes[ii].depth;
        nodeCountValid = 0;
        }
       
       
        
       }
        
        
        
        
        
        
       
      
      //all nodes up to now finished, update currentDepth
      currentDepth++;
    
  }
       
       
  }    
       
}
       
}
     
      
   
   
  
void mouseMoved(){
    
    if ( millis() - lastTime2 > nodeDelay){
      noStroke();
      fill(200);
      rect(0,0,200,50);
         
     }
        
    for (int i=0; i < nbrNodes; i++){
      Node nodei = nodes[i];
      if(nodei.isWithin(mouseX,mouseY)){
        println("Mouse on node name = [" + nodei.name + "], depth = " + nodei.depth + ", index = " + nodei.index + " freq = " + nodei.freq);
        String s = "Node: " + nodei.name;
        textSize(20);
        fill(0);
        text(s, 20, 20);
         lastTime2 = millis(); 
      }
    }
   
 
 
}     