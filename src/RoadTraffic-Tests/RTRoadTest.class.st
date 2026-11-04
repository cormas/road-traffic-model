"
I test how a road measures its length, wears out and gets repaired.

## Responsibility:

- Check the length, wear, uses and cost of a road.
- Check what a use and a repair do to a road.

## Collaborators:

- `RTRoad`: the class under test.
- `RTRoadTrafficModel`: holds a small grid, without the map of the town.

## Public API and Key Messages

Run me as any `TestCase`.

## Internal Representation

- `model`: an `RTRoadTrafficModel` with a 10x10 grid.
- `road`: an `RTRoad` from plot 1@1 to plot 3@6, which needs 5 steps on a grid with 8 neighbours.

"
Class {
	#name : 'RTRoadTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'road'
	],
	#category : 'RoadTraffic-Tests',
	#package : 'RoadTraffic-Tests'
}

{ #category : 'running' }
RTRoadTest >> setUp [

	super setUp.
	RTRoad wearPerUse: 0.02.
	model := RTRoadTrafficModel new.
	model
		createGridNumberOfRows: 10
		numberOfColumns: 10
		neighbourhood: 8
		closed: true.
	road := model
		        newEntity: RTRoad
		        from: (model cellAt: 1 at: 1)
		        to: (model cellAt: 3 at: 6)
]

{ #category : 'tests' }
RTRoadTest >> testCostIsLengthTimesWear [

	RTRoad wearPerUse: 0.5.

	road recordUse.

	self assert: road cost equals: 7.5
]

{ #category : 'tests' }
RTRoadTest >> testEachUseWearsTheRoad [

	road recordUse.
	road recordUse.

	self assert: (road wear closeTo: 1.04).
	self assert: road uses equals: 2
]

{ #category : 'tests' }
RTRoadTest >> testLengthIsTheNumberOfStepsAlongTheRoad [

	self assert: road length equals: 5.
	self assert: road length equals: (road from wayTo: road to) size
]

{ #category : 'tests' }
RTRoadTest >> testNewRoadIsUnworn [

	self assert: road wear equals: 1.
	self assert: road uses equals: 0.
	self assert: road cost equals: 5
]

{ #category : 'tests' }
RTRoadTest >> testRepairRemovesWearAndKeepsUses [

	road recordUse.

	road repair.

	self assert: road wear equals: 1.
	self assert: road uses equals: 1
]

{ #category : 'tests' }
RTRoadTest >> testSimulationSetsTheDefaultWearPerUse [

	RTRoad wearPerUse: 0.5.

	(CMSimulation for: RTRoadTrafficModel new)
		activeInitSelector: #initTown;
		initializeSimulation.

	self assert: RTRoad wearPerUse equals: 0.02
]

{ #category : 'tests' }
RTRoadTest >> testWearPerUseIsAParameter [

	RTRoad wearPerUse: 0.5.

	road recordUse.

	self assert: road wear equals: 1.5
]
