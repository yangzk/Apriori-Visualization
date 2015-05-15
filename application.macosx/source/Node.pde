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
    
    color fillColor;
    
    
    
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
        this.fillColor = color(0,0,0,120);
                
      }else if (this.freq >= 0){
        
         //prune due to low support --> red
        this.fillColor = color(255,0,0); 
                 
      }else if (this.freq == -1){
        
        //prune due to absence of subset --> blue       
        this.fillColor = color(0,0,255);  
        
       }
    }
    
    
    
    int getDepth(){
      return depth;
    }
    
    int getIndex(){
      return index;
    }
    
    float x(){
      return this.x;
    }
    
    float y(){
      return this.y;
    }
    
    float pr(){
      return this.r;
    }
    
    boolean isWithin(float px, float py){
      float dx = px - this.x;
      float dy = py - this.y;
      return sqrt(dx*dx + dy*dy) <= this.r *2.0;
    }
    
    float toDist(float px, float py){
      float dx = px - this.x;
      float dy = py - this.y;
      return sqrt(dx*dx + dy*dy) ;
    }
    
    void numNodesInLayer(int n){
      this.numNodesLayer = n;
    }
      
    
 
    
    public void display(){
      
      noStroke();
      fill(fillColor);
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
