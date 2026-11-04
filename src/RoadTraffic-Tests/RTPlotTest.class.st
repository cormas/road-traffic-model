"
I test how a plot finds the road to take towards another plot.

## Responsibility:

- Check that the cheapest route wins, whether it is short or just less worn.
- Check that routes respect one-way roads and only follow roads.

## Collaborators:

- `RTPlot`: the class under test.
- `RTRoad`: the roads of each small map.
- `RTRoadTrafficModel`: holds a small grid, without the map of the town.

## Public API and Key Messages

Run me as any `TestCase`.

## Internal Representation

- `model`: an `RTRoadTrafficModel` with a 10x10 grid.
- `start`, `middle` and `end`: plots of the small maps. The road from `start` to `end` has a length of 5, and the way through `middle` has a length of 6.

"
Class {
	#name : 'RTPlotTest',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'start',
		'middle',
		'end'
	],
	#category : 'RoadTraffic-Tests',
	#package : 'RoadTraffic-Tests'
}

{ #category : 'private' }
RTPlotTest >> roadFrom: aPlot to: anotherPlot [

	^ model newEntity: RTRoad from: aPlot to: anotherPlot
]

{ #category : 'running' }
RTPlotTest >> setUp [

	super setUp.
	model := RTRoadTrafficModel new.
	RTRoad wearPerUse: 1.
	model
		createGridNumberOfRows: 10
		numberOfColumns: 10
		neighbourhood: 8
		closed: true.
	start := model cellAt: 1 at: 1.
	middle := model cellAt: 4 at: 3.
	end := model cellAt: 1 at: 6
]

{ #category : 'tests' }
RTPlotTest >> testAnswersTheFirstRoadOfAWayOfSeveralRoads [

	| first second |
	first := self roadFrom: start to: middle.
	second := self roadFrom: middle to: end.

	self assert: (start cheapestRoadTo: end) equals: first.
	self assert: (middle cheapestRoadTo: end) equals: second
]

{ #category : 'tests' }
RTPlotTest >> testNoRouteIsAnError [

	(self roadFrom: end to: start) beOneWay.

	self should: [ start cheapestRoadTo: end ] raise: Error
]

{ #category : 'tests' }
RTPlotTest >> testOneWayRoadIsNotTakenBackwards [

	| firstOfTheLongWay |
	(self roadFrom: end to: start) beOneWay.
	firstOfTheLongWay := self roadFrom: start to: middle.
	self roadFrom: middle to: end.

	self assert: (start cheapestRoadTo: end) equals: firstOfTheLongWay
]

{ #category : 'tests' }
RTPlotTest >> testRoutesOnlyFollowRoads [

	| road |
	model newEntity: RTHomeLink from: start to: end.
	road := self roadFrom: start to: middle.
	self roadFrom: middle to: end.

	self assert: (start cheapestRoadTo: end) equals: road
]

{ #category : 'tests' }
RTPlotTest >> testShortRoadBeatsALongerWay [

	| direct |
	direct := self roadFrom: start to: end.
	self roadFrom: start to: middle.
	self roadFrom: middle to: end.

	self assert: (start cheapestRoadTo: end) equals: direct
]

{ #category : 'tests' }
RTPlotTest >> testTwoWayRoadCanBeTravelledBothWays [

	| road |
	road := self roadFrom: start to: end.

	self assert: (end cheapestRoadTo: start) equals: road
]

{ #category : 'tests' }
RTPlotTest >> testWornShortRoadLosesToALongerCleanWay [

	| direct firstOfTheLongWay |
	direct := self roadFrom: start to: end.
	firstOfTheLongWay := self roadFrom: start to: middle.
	self roadFrom: middle to: end.

	direct recordUse.

	self assert: (start cheapestRoadTo: end) equals: firstOfTheLongWay
]
