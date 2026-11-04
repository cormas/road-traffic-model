"
I test how the town repairs its roads once a day.

## Responsibility:

- Check that the most worn roads are the ones repaired.
- Check that repairs happen at the start of each day, whichever way people walk.
- Check that repairs keep the town in better condition.

## Collaborators:

- `RTRoadTrafficModel`: the model under test.
- `RTRoad`: the roads being repaired.

## Public API and Key Messages

Run me as any `TestCase`.

## Internal Representation

- `model`: an `RTRoadTrafficModel` with a 10x10 grid and three roads, which repairs one road a day.
- `worst`, `worn` and `clean`: the three roads, with a wear of 3, 2 and 1.

"
Class {
	#name : 'RTRepairTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'worst',
		'worn',
		'clean'
	],
	#category : 'RoadTraffic-Tests',
	#package : 'RoadTraffic-Tests'
}

{ #category : 'private' }
RTRepairTest >> assertRepairsOnlyAtTheStartOfADayWith: aControlSelector [

	model simulationContext currentTimeStep: 2.
	model perform: aControlSelector.
	self assert: worst wear equals: 3.

	model simulationContext currentTimeStep: 100.
	model perform: aControlSelector.
	self assert: worst wear equals: 3.

	model simulationContext currentTimeStep: 101.
	model perform: aControlSelector.
	self assert: worst wear equals: 1
]

{ #category : 'private' }
RTRepairTest >> meanWearAfterFiveDaysWithRepairsPerDay: aNumber [

	| town simulation |
	town := RTRoadTrafficModel new.
	simulation := CMSimulation for: town.
	simulation
		randomSeed: 42;
		activeInitSelector: #initTown;
		activeControlSelector: #stepAlongTheLine;
		initializeSimulation.
	town repairsPerDay: aNumber.
	500 timesRepeat: [ simulation runStep ].
	^ (town @@ RTRoad inject: 0 into: [ :sum :road | sum + road wear ])
	  / (town @@ RTRoad) size
]

{ #category : 'running' }
RTRepairTest >> setUp [

	super setUp.
	model := RTRoadTrafficModel new.
	RTRoad wearPerUse: 1.
	model
		createGridNumberOfRows: 10
		numberOfColumns: 10
		neighbourhood: 8
		closed: true.
	model repairsPerDay: 1.
	clean := model
		         newEntity: RTRoad
		         from: (model cellAt: 1 at: 1)
		         to: (model cellAt: 1 at: 3).
	worst := model
		         newEntity: RTRoad
		         from: (model cellAt: 3 at: 1)
		         to: (model cellAt: 3 at: 3).
	worn := model
		        newEntity: RTRoad
		        from: (model cellAt: 5 at: 1)
		        to: (model cellAt: 5 at: 3).
	worst
		recordUse;
		recordUse.
	worn recordUse
]

{ #category : 'tests' }
RTRepairTest >> testDayStepRepairsTheMostWornRoad [

	model dayStep.

	self assert: worst wear equals: 1.
	self assert: worn wear equals: 2
]

{ #category : 'tests' }
RTRepairTest >> testMeanAndMaxWearOfTheTown [

	self assert: model meanWear equals: 2.
	self assert: model maxWear equals: 3
]

{ #category : 'tests' }
RTRepairTest >> testRepairsKeepTheTownInBetterCondition [

	self assert: (self meanWearAfterFiveDaysWithRepairsPerDay: 5)
		< (self meanWearAfterFiveDaysWithRepairsPerDay: 0)
]

{ #category : 'tests' }
RTRepairTest >> testRepairsOnlyAtTheStartOfADayWhenWalkingAlongTheLine [

	self assertRepairsOnlyAtTheStartOfADayWith: #stepAlongTheLine
]

{ #category : 'tests' }
RTRepairTest >> testRepairsOnlyAtTheStartOfADayWhenWalkingWithMoveTowards [

	self assertRepairsOnlyAtTheStartOfADayWith: #stepWithMoveTowards
]

{ #category : 'tests' }
RTRepairTest >> testRepairsPerDaySetsHowManyRoadsAreRepaired [

	model repairsPerDay: 2.

	model dayStep.

	self assert: worst wear equals: 1.
	self assert: worn wear equals: 1
]
