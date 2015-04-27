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
      float tSpeed = Dtheta *1.0 /steps;
      float rSpeed = Drad * 1.0/steps;
      
       
      for(int t=0; t<steps; t++){
        pv[t] = new PVector(0.0, 0.0);
         
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
    stroke(0,0,0,20);
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
      float tSpeed = Dtheta *1.0 /steps;
      float rSpeed = Drad * 1.0/steps;
      
       
      for(int t=0; t<steps; t++){
        pv[t] = new PVector(0.0, 0.0);
         
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
