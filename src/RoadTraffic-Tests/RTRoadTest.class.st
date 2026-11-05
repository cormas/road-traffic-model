"
I test how a road wears out and gets repaired.

## Responsibility:

- Check the wear, uses and cost of a road.
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

{ #category : 'running' }
RTRoadTest >> tearDown [

	RTRoad resetClassSideParameters.
	super tearDown
]

{ #category : 'tests' }
RTRoadTest >> testAStreetWithNoRoadsIsUnworn [

	self assert: (model newEntity: RTStreet) meanWear equals: 1
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
RTRoadTest >> testMeanWearOfAStreetIsTheAverageOfItsRoads [

	| street other |
	other := model
		         newEntity: RTRoad
		         from: (model cellAt: 3 at: 6)
		         to: (model cellAt: 5 at: 6).
	street := model newEntity: RTStreet.
	street addAll: {
			road.
			other }.
	road recordUse.
	self assert: (street meanWear closeTo: 1.01)
]

{ #category : 'tests' }
RTRoadTest >> testMeanWearOfTheTownIsTheAverageOfAllItsRoads [

	| street town other |
	other := model
		         newEntity: RTRoad
		         from: (model cellAt: 3 at: 6)
		         to: (model cellAt: 5 at: 6).
	street := model newEntity: RTStreet.
	street add: road.
	town := model newEntity: RTTown.
	town add: street.
	town add: other.
	road recordUse.
	self assert: (town meanWear closeTo: 1.01)
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
RTRoadTest >> testWearOfOneStreetDoesNotAffectAnother [

	| worn clean |
	worn := model newEntity: RTStreet.
	worn add: road.
	clean := model newEntity: RTStreet.
	clean add: (model
			 newEntity: RTRoad
			 from: (model cellAt: 3 at: 6)
			 to: (model cellAt: 5 at: 6)).
	road recordUse.
	self assert: worn meanWear > 1.
	self assert: clean meanWear equals: 1
]
