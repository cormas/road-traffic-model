"
I test that the town of the road traffic model works as a town.

## Responsibility:

- Check that everyone can get to work and back, with and without one-way roads.
- Check that one-way roads only appear in the town that asks for them, and that they only go one way.

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

	self assert: model residentialPlots isNotEmpty.
	self assert: model industrialPlots isNotEmpty.
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
RTRoadTrafficModelTest >> testAOneWayStreetRunsOneWayFromEndToEnd [
	"Traffic on a street goes both ways on all of its roads, or one way along all of them"

	| town oneWays |
	town := RTRoadTrafficModel new.
	town initTownWithOneWays.
	oneWays := town @@ RTStreet select: [ :street |
		           street links anySatisfy: [ :road | road isOneWay ] ].
	self deny: oneWays isEmpty.
	oneWays do: [ :street |
			self assert: (street links allSatisfy: [ :road | road isOneWay ]).
			self assert: street sources size equals: 1.
			self assert: street sinks size equals: 1 ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryRoadIsInExactlyOneStreet [

	self initializeWith: #initTown.

	self assert: (model @@ RTRoad) isNotEmpty.
	model @@ RTRoad do: [ :road |
		self assert: (road networksOfClass: RTStreet) size equals: 1 ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryStreetIsALineOrALoop [
	"A street never branches: each of its plots touches at most two of its roads. It is in one piece, so it has two ends, or none when it is a loop."

	| town streets |
	town := RTRoadTrafficModel new.
	town initTown.
	streets := town @@ RTStreet.
	self deny: streets isEmpty.
	streets do: [ :street |
			street entities do: [ :plot |
				self assert: (plot linksIn: street) size <= 2 ].
			self
				assert: (street entities first allLinkedEntitiesIn: street) size
				equals: street entities size - 1.
			self assert: (#( 0 2 ) includes: street terminals size) ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryStreetIsOnePiece [

	self initializeWith: #initTown.

	self assert: model town members isNotEmpty.
	model town members do: [ :street |
			self
				assert: (street links first from allLinksIn: street) size
				equals: street links size ]
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
RTRoadTrafficModelTest >> testEveryoneIsAtHomeOrAtWorkOrOnTheRoadAtAnyTime [

	| simulation |
	model := RTRoadTrafficModel new.
	simulation := CMSimulation for: model.
	simulation
		randomSeed: 42;
		activeInitSelector: #initTown;
		activeControlSelector: #step;
		initializeSimulation.

	self assert: model peopleAtHome equals: (model @@ RTPerson) size.
	100 timesRepeat: [
			simulation runStep.
			self
				assert:
				model peopleAtHome + model peopleAtWork + model peopleOnTheRoad
				equals: (model @@ RTPerson) size ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testEveryoneLivesOnAResidentialPlotAndWorksOnAnIndustrialOne [

	self initializeWith: #initTown.

	self assert: (model @@ RTPerson) isNotEmpty.
	model @@ RTPerson do: [ :person |
			self assert: person home isResidential.
			self assert: person workplace isIndustrial ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testFollowingTheCheapestRoadsLeadsToWork [

	self initializeWith: #initTownWithOneWays.

	self assert: (model @@ RTPerson) isNotEmpty.
	model @@ RTPerson do: [ :person |
			| plot steps |
			plot := person home.
			steps := 0.
			[ plot = person workplace ] whileFalse: [
					plot := (plot cheapestRoadTo: person workplace) otherEndOf: plot.
					steps := steps + 1.
					self assert: steps < (model @@ RTRoad) size ] ]
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
RTRoadTrafficModelTest >> testPeopleGoToWorkAndComeBackHomeOverADay [

	| simulation people |
	model := RTRoadTrafficModel new.
	simulation := CMSimulation for: model.
	simulation
		randomSeed: 42;
		activeInitSelector: #initTown;
		activeControlSelector: #step;
		initializeSimulation.
	people := model @@ RTPerson.

	60 timesRepeat: [ simulation runStep ].
	self assert:
		(people count: [ :person | person cell = person workplace ])
		> (people size / 2).

	40 timesRepeat: [ simulation runStep ].
	self assert: (people count: [ :person | person cell = person home ])
		> (people size / 2)
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testPeopleStartAtHome [

	self initializeWith: #initTown.

	self assert: (model @@ RTPerson) isNotEmpty.
	model @@ RTPerson do: [ :person |
		self assert: person cell equals: person home ]
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testRoadsOfTheTownAreTwoWay [

	self initializeWith: #initTown.

	self assert:
		(model @@ RTRoad noneSatisfy: [ :road | road isDirected ])
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testStepOfDayRepeatsEveryDay [

	self initializeWith: #initTown.

	model simulationContext currentTimeStep: 1.
	self assert: model stepOfDay equals: 1.
	model simulationContext currentTimeStep: 100.
	self assert: model stepOfDay equals: 100.
	model simulationContext currentTimeStep: 101.
	self assert: model stepOfDay equals: 1
]

{ #category : 'tests' }
RTRoadTrafficModelTest >> testTheTownHoldsEveryRoad [

	self initializeWith: #initTown.

	self assert: (model @@ RTRoad) isNotEmpty.
	model @@ RTRoad do: [ :road |
		self assert: (model town includes: road) ]
]
