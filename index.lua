dofile('interfaces/List.lua')

--Load in the modules
decider = dofile('deciders/default.lua')

myList = List.CreateList()
List.Push(myList, "Hello")


vba.print(myList.FirstIndex)
decider.ChooseInput(decider, nil)