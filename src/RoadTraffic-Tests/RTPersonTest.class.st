"
I test how a person decides where to go and walks there.

## Responsibility:

- Check that the destination follows the time of day.
- Check how fast a person walks, and how wear slows them down.
- Check what a person does at junctions, at their destination and when they are late.

## Collaborators:

- `RTPerson`: the class under test.
- `RTRoad`: the two roads of a small map.
- `RTRoadTrafficModel`: holds a small grid and the time of day, without the map of the town.

## Public API and Key Messages

Run me as any `TestCase`.

## Internal Representation

- `model`: an `RTRoadTrafficModel` with a 10x10 grid.
- `person`: a person who walks one cell per step, and leaves home at step 10 and work at step 60.
- `home`, `junction` and `workplace`: plots 1@1, 1@4 and 1@7 on one row, so that positions are exact.
- `firstRoad` and `secondRoad`: the roads between them, 3 cells long.

"
Class {
	#name : 'RTPersonTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'person',
		'home',
		'junction',
		'workplace',
		'firstRoad',
		'secondRoad'
	],
	#category : 'RoadTraffic-Tests',
	#package : 'RoadTraffic-Tests'
}

{ #category : 'private' }
RTPersonTest >> distanceOf: aWalker fromLineBetween: aCell and: anotherCell [
	"In cell widths, from where the walker is drawn to the line drawn between the centers of the two cells"

	| grid a b p |
	grid := aCell spaceModel neighbourhoodConfiguration.
	a := grid centerOnGridOf: aCell.
	b := grid centerOnGridOf: anotherCell.
	p := grid gridPositionOf: aWalker cell at: aWalker positionInCell.
	^ (p x - a x * (b y - a y) - (p y - a y * (b x - a x))) abs
	  / (b - a) r
]

{ #category : 'private' }
RTPersonTest >> personOnSlopedRoadFrom: aHome to: aWorkplace [

	| walker |
	model town add: (model newEntity: RTRoad from: aHome to: aWorkplace).
	walker := model newEntity: RTPerson locatedAt: aHome.
	model newEntity: RTHomeLink from: walker to: aHome.
	model newEntity: RTWorkLink from: walker to: aWorkplace.
	^ walker
		  speed: 1;
		  leaveHomeStep: 10;
		  leaveWorkStep: 60;
		  yourself
]

{ #category : 'running' }
RTPersonTest >> setUp [

	super setUp.
	model := RTRoadTrafficModel new.
	RTRoad wearPerUse: 0.
	model
		createGridNumberOfRows: 10
		numberOfColumns: 10
		neighbourhood: 8
		closed: true.
	home := model cellAt: 1 at: 1.
	junction := model cellAt: 1 at: 4.
	workplace := model cellAt: 1 at: 7.
	firstRoad := model newEntity: RTRoad from: home to: junction.
	secondRoad := model newEntity: RTRoad from: junction to: workplace.
	(model newEntity: RTTown) addAll: { firstRoad. secondRoad }.
	person := model newEntity: RTPerson locatedAt: home.
	model newEntity: RTHomeLink from: person to: home.
	model newEntity: RTWorkLink from: person to: workplace.
	person
		speed: 1;
		leaveHomeStep: 10;
		leaveWorkStep: 60
]

{ #category : 'running' }
RTPersonTest >> tearDown [

	RTRoad resetClassSideParameters.
	super tearDown
]

{ #category : 'tests' }
RTPersonTest >> testContinuesThroughAJunctionAndStaysAtWork [

	self timeStep: 10.

	self walkTimes: 9.

	self assert: person cell equals: workplace.
	self assert: firstRoad uses equals: 1.
	self assert: secondRoad uses equals: 1
]

{ #category : 'tests' }
RTPersonTest >> testDestinationFollowsTheTimeOfDay [

	self timeStep: 9.
	self assert: person destination equals: home.
	self timeStep: 10.
	self assert: person destination equals: workplace.
	self timeStep: 60.
	self assert: person destination equals: workplace.
	self timeStep: 61.
	self assert: person destination equals: home.
	self timeStep: 110.
	self assert: person destination equals: workplace
]

{ #category : 'tests' }
RTPersonTest >> testEnteringARoadUsesItOnce [

	self timeStep: 10.

	self walkTimes: 2.

	self assert: firstRoad uses equals: 1.
	self assert: secondRoad uses equals: 0
]

{ #category : 'tests' }
RTPersonTest >> testFasterPersonWalksMoreCells [

	self timeStep: 10.
	person speed: 1.5.

	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 2).

	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 4)
]

{ #category : 'tests' }
RTPersonTest >> testIsAtHomeOnTheRoadOrAtWork [

	self timeStep: 5.
	person walk.
	self assert: person isAtHome.
	self deny: person isOnRoad.
	self deny: person isAtWork.

	self timeStep: 10.
	person walk.
	self assert: person isOnRoad.
	self deny: person isAtHome.
	self deny: person isAtWork.

	self walkTimes: 5.
	self assert: person isAtWork.
	self deny: person isOnRoad.
	self deny: person isAtHome
]

{ #category : 'tests' }
RTPersonTest >> testLatePersonFinishesTheRoadThenTurnsBack [

	self timeStep: 10.
	self walkTimes: 1.

	self timeStep: 61.
	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 3).

	self walkTimes: 1.
	self assert: person cell equals: junction.
	self assert: firstRoad uses equals: 2.

	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 3)
]

{ #category : 'tests' }
RTPersonTest >> testStaysAtHomeBeforeLeaving [

	self timeStep: 5.

	self walkTimes: 3.

	self assert: person cell equals: home.
	self assert: firstRoad uses equals: 0
]

{ #category : 'tests' }
RTPersonTest >> testStepsLeftAtAJunctionAreLost [
	"At a speed of 1.5, the second step reaches the junction with half a cell to spare, and the person starts the next road from there at the next step"

	self timeStep: 10.
	person speed: 1.5.
	self walkTimes: 2.
	self assert: (person isAtCenterOf: junction).
	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 5).
	self assert:
		(person positionInCell x closeTo: 1.0 precision: 0.000001)
]

{ #category : 'tests' }
RTPersonTest >> testWalksExactlyOnASlopedRoadAndArrives [
	"The road is about 7.3 cells long, so at a speed of 1 it takes 8 steps"

	| from to walker |
	from := model cellAt: 3 at: 1.
	to := model cellAt: 5 at: 8.
	walker := self personOnSlopedRoadFrom: from to: to.
	self timeStep: 10.
	7 timesRepeat: [
			walker walk.
			self assert: walker isOnRoad.
			self assert:
				(self distanceOf: walker fromLineBetween: from and: to) < 0.000001 ].
	walker walk.
	self assert: walker isAtWork.
	self assert: (walker isAtCenterOf: to)
]

{ #category : 'tests' }
RTPersonTest >> testWalksExactlyOnASlopedRoadInBothDirections [

	| from to walker |
	from := model cellAt: 3 at: 1.
	to := model cellAt: 5 at: 8.
	walker := self personOnSlopedRoadFrom: from to: to.
	self timeStep: 10.
	8 timesRepeat: [ walker walk ].
	self timeStep: 61.
	7 timesRepeat: [
			walker walk.
			self assert:
				(self distanceOf: walker fromLineBetween: from and: to) < 0.000001 ].
	walker walk.
	self assert: walker isAtHome.
	self assert: (walker isAtCenterOf: from)
]

{ #category : 'tests' }
RTPersonTest >> testWalksOneCellPerStepAtSpeedOne [

	self timeStep: 10.

	self walkTimes: 2.

	self assert: person cell equals: (model cellAt: 1 at: 3)
]

{ #category : 'tests' }
RTPersonTest >> testWornRoadSlowsAPersonDown [

	self timeStep: 10.
	RTRoad wearPerUse: 1.

	self walkTimes: 1.
	self assert: person cell equals: home.

	self walkTimes: 1.
	self assert: person cell equals: (model cellAt: 1 at: 2)
]

{ #category : 'private' }
RTPersonTest >> timeStep: aNumber [

	model simulationContext currentTimeStep: aNumber
]

{ #category : 'private' }
RTPersonTest >> walkTimes: aNumber [

	aNumber timesRepeat: [ person walk ]
]
