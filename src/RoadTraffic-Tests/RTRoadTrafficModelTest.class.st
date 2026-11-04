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
RTRoadTrafficModelTest >> assertEveryHomeReachesEveryWorkplaceAndBack [

	model residentialPlots do: [ :home |
			model industrialPlots do: [ :workplace |
					self assert:
						((home allDownstreamEntitiesLinkedBy: RTRoad) includes:
							 workplace).
					self assert:
						((workplace allDownstreamEntitiesLinkedBy: RTRoad) includes:
							 home) ] ]
]

{ #category : 'private' }
RTRoadTrafficModelTest >> initializeWith: anInitSelector [

	model := RTRoadTrafficModel new.
	(CMSimulation for: model)
		randomSeed: 42;
		activeInitSelector: anInitSelector;
		initializeSimulation
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryoneCanGetToWorkAndBack [

	self initializeWith: #initTown.

	self assertEveryHomeReachesEveryWorkplaceAndBack
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryoneCanGetToWorkAndBackWithOneWays [

	self initializeWith: #initTownWithOneWays.

	self assertEveryHomeReachesEveryWorkplaceAndBack
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testOneWayRoadGoesFromItsFirstPlotToItsSecond [

	| first second |
	self initializeWith: #initTownWithOneWays.
	first := model cellAt: 25 at: 25.
	second := model cellAt: 25 at: 33.

	self assert: ((first nextEntitiesLinkedBy: RTRoad) includes: second).
	self deny: ((second nextEntitiesLinkedBy: RTRoad) includes: first)
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testPlotsHaveNoBorder [

	self initializeWith: #initTown.

	self assert: (model cellAt: 1 at: 1) activePov borderWidth equals: 0.
	self
		assert: model residentialPlots first activePov borderWidth
		equals: 0.
	self
		assert: model industrialPlots first activePov borderWidth
		equals: 0
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testPlotsOfTheTownHaveEightNeighbours [

	self initializeWith: #initTown.

	self assert: (model cellAt: 25 at: 25) neighbourhood size equals: 8
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testPlotsShowWhatTheyAre [

	| colors |
	self initializeWith: #initTown.

	colors := {
		          model residentialPlots first activePov color.
		          model industrialPlots first activePov color.
		          (model cellAt: 1 at: 1) activePov color } asSet.

	self assert: colors size equals: 3
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testRoadsOfTheTownAreTwoWay [

	self initializeWith: #initTown.

	self assert:
		(model @@ RTRoad noneSatisfy: [ :road | road isDirected ])
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTownHasResidentialAndIndustrialPlots [

	self initializeWith: #initTown.

	self assert: model residentialPlots size equals: 8.
	self assert: model industrialPlots size equals: 3.
	self assert:
		(model residentialPlots includes: (model cellAt: 6 at: 8)).
	self assert:
		(model industrialPlots includes: (model cellAt: 38 at: 45))
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTownIsAGridOfFiftyByFiftyPlots [

	self initializeWith: #initTown.

	self assert: model spaceModel numberOfRows equals: 50.
	self assert: model spaceModel numberOfColumns equals: 50.
	self assert: (model @@ RTPlot) size equals: 2500
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTownIsANetworkOfRoadsBetweenPlots [

	self initializeWith: #initTown.

	self assert: (model @@ RTRoad) size equals: 43.
	self assert:
		(((model cellAt: 18 at: 22) entitiesLinkedBy: RTRoad) includes:
			 (model cellAt: 19 at: 30))
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTownWithOneWaysHasFiveOneWayRoads [

	self initializeWith: #initTownWithOneWays.

	self
		assert: (model @@ RTRoad count: [ :road | road isDirected ])
		equals: 5
]
