# ios-list-crash-repro
For Apple bug reporting - demonstrates a desynchronisation condition

Tested with simulators for iPhone 11 13.3.1 and a real iPhone 8 13.3.1

Run the code then rotate the device. Eventually after a rotation some aspect of the internal 
list representation will desync with the correct data and an assertion will fail internally. 

Sometimes you will instead see a `NSInternalInconsistencyException` from `UITableView` occur - 
which I believe to be a symptom of the same internal desynchronisation. 
