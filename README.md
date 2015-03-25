# Apriori-Visualization 

This is an algorithm to visualize the Apriori Algorithm developed with Processing (processing.org). It contains these files:

JsonTest.pde -- the main file to run. 

  widthW -- window width
  
  heightW -- window height
  
  displayCartesian -- to draw horizontal tree or polar tree
  
  speed -- draw speed 1 to 500
  
Node.pde -- Node class

Spring.pde -- Spring class which connects two nodes

./data/test.json -- the node information to read during the algorithm. It is a JSON format with the following structure:

  minSupport -- minimum support threshold
  
  numNodes -- total number of nodes include those need to be pruned
  
    Node
    
      Name -- name of items, e.g. {1 2 3}
      
      ID -- ID of the node, which unique with its depth and index, e.g. {0 1}
      
      frequency -- frequency of the node, if it is pruned with absence of subset in parent layer, frequency = -1
      
      parentID -- parentID
