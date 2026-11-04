"
I test the road traffic model.

## Responsibility:

- Check the town that the init methods of the model create.

## Collaborators:

- `RTRoadTrafficModel`: the model under test, initialized through a `CMSimulation`.

## Public API and Key Messages

Run me as any `TestCase`.

## Internal Representation

- `model`: the `RTRoadTrafficModel` under test.

"
Class {
	#name : 'RTRoadTrafficModelTest',
	#superclass : 'TestCase',
	#instVars : [
		'model'
	],
	#category : 'RoadTraffic-Tests',
	#package : 'RoadTraffic-Tests'
}

{ #category : 'private' }
RTRoadTrafficModelTest >> initializeWith: anInitSelector [

	model := RTRoadTrafficModel new.
	(CMSimulation for: model)
		randomSeed: 42;
		activeInitSelector: anInitSelector;
		initializeSimulation
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testPlotsOfTheTownHaveEightNeighbours [

	self initializeWith: #initTown.

	self assert: (model cellAt: 25 at: 25) neighbourhood size equals: 8
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTownIsAGridOfFiftyByFiftyPlots [

	self initializeWith: #initTown.

	self assert: model spaceModel numberOfRows equals: 50.
	self assert: model spaceModel numberOfColumns equals: 50.
	self assert: (model @@ RTPlot) size equals: 2500
]
