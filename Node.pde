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
    PVector centroid = new PVector(0,0);;
    
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
      
    
   
    
    public void moveto(float px, float py, float time){
      
      if( this.x != px && this.y != py){
        PVector dist = new PVector(px - this.x, py - this.y);
        PVector speed = PVector.div(dist,time);
         
        this.x = this.x + speed.x;
        this.y = this.y + speed.y;
        
      }
        
    }
    
    public void display(){
      
      noStroke();
      
      if (this.freq >= minSup ){
        
        //node with freq > minSup --> black
        fill(0,0,0,120);
        ellipse(this.x, this.y, this.r, this.r);
        
      }else if (this.freq >= 0){
        
         //prune due to low support --> red
        fill(255,0,0,120); 
        ellipse(this.x, this.y, this.r, this.r);
        
      }else if (this.freq == -1){
        
        //prune due to absence of subset --> blue       
        fill(0,0,255,120);  
        ellipse(this.x, this.y, this.r, this.r);
        
      }
    }
    
    
    public void highlight(){
      
      float newr = this.r ;
      
      stroke(0,255,0);
      strokeWeight(3);
      
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
        
      }
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
      
      float LayerSpace  = this.layerSpace;
      
      this.highlight();
      
      Iterator<Node> parItr = this.parents.iterator();
            
      while(parItr.hasNext()){
        
        Node parNode = (Node)parItr.next();
        parNode.highlight();
              
        Spring spring = new Spring(parNode, this);        
            
        spring.highlight();
        
        parNode.expand(); 
         
        
      }
      
      
    }
    
    
  }
