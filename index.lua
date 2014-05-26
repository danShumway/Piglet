dofile('interfaces/List.lua')

--Load in the modules
myDecider = dofile('deciders/default.lua')
pastInputs = List.CreateList()
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})
List.Push(pastInputs, {})


pastResults = List.CreateList()
List.Push(pastResults, 10)
List.Push(pastResults, 4)
List.Push(pastResults, 3)
List.Push(pastResults, 2)
List.Push(pastResults, 5)
List.Push(pastResults, 6)
List.Push(pastResults, 7)
List.Push(pastResults, 8)
List.Push(pastResults, 9)
List.Push(pastResults, 1)


myDecider.ChooseInput(myDecider, pastInputs, pastResults, 10, 5)