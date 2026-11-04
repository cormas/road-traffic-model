"
I am one straight segment of road between two plots. A street that bends is a chain of several of me.

## Responsibility:

- Connect two junctions of the town, which can be many cells apart.
- Know whether traffic may only go from my `from` end to my `to` end.
- Wear out with each use, which makes me more costly to travel, until I am repaired.
- Know the cells that my straight line crosses.
- Show my wear as a color and my traffic as a width.

## Collaborators:

- `RTRoadTrafficModel`: creates me from its table of roads.
- `RTPlot`: my two ends.

## Public API and Key Messages

- `length` answers the number of steps to walk from one end to the other.
- `cellsTowards:` answers the cells of my straight line, in order, ending at the given end.
- `wear` starts at 1, and `recordUse` raises it by the parameter `wearPerUse`.
- `cost` answers `length * wear`, which is what choosing a route compares.
- `repair` sets `wear` back to 1.
- `uses` counts all uses, and repairs do not reset it.
- `beOneWay` makes me one-way, from `from` to `to`. `isOneWay` and `isDirected` tell whether I am.
- `povWear`, `povTraffic` and `povWearAndTraffic` are my points of view.

```
road := model newEntity: RTRoad from: plotA to: plotB.
road recordUse.
road cost
```

## Internal Representation

- `oneWay`: a boolean, false until I am told otherwise.
- `wear`: a number of at least 1.
- `uses`: an integer.

"
Class {
	#name : 'RTRoad',
	#superclass : 'CMLink',
	#instVars : [
		'oneWay',
		'wear',
		'uses'
	],
	#classInstVars : [
		'wearPerUse'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'examples' }
RTRoad class >> exampleWornRoad [

	<sampleInstance>
	| road |
	road := (RTRoadTrafficModel exampleTown @@ self) first.
	road recordUse.
	^ road
]

{ #category : 'parameters' }
RTRoad class >> wearPerUse [

	<parameterFloatMin: 0 max: 1 default: 0.02>
	^ wearPerUse
]

{ #category : 'parameters' }
RTRoad class >> wearPerUse: aNumber [

	wearPerUse := aNumber
]

{ #category : 'accessing' }
RTRoad >> beOneWay [

	oneWay := true
]

{ #category : 'accessing' }
RTRoad >> cellsTowards: anEnd [
	"The cells that my straight line crosses, in order, from my other end to anEnd. There is one cell per step, so a person can walk them one by one."

	| start steps |
	start := self otherEndOf: anEnd.
	steps := self length.
	^ (0 to: steps) collect: [ :step |
			  | fraction |
			  fraction := step / steps.
			  self cormasModel
				  cellAt:
					  (start rowNumber
					   + (anEnd rowNumber - start rowNumber * fraction)) rounded
				  at: (start columnNumber
					   + (anEnd columnNumber - start columnNumber * fraction))
						  rounded ]
]

{ #category : 'accessing' }
RTRoad >> cost [
	"What choosing a route compares. It is also how long a person takes to cross me at a speed of one cell per step."

	^ self length * self wear
]

{ #category : 'initialization' }
RTRoad >> initialize [

	super initialize.
	oneWay := false.
	wear := 1.
	uses := 0
]

{ #category : 'testing' }
RTRoad >> isDirected [

	^ self isOneWay
]

{ #category : 'testing' }
RTRoad >> isOneWay [

	^ oneWay
]

{ #category : 'accessing' }
RTRoad >> length [
	"The number of steps to walk from one end to the other."

	^ self from distanceTo: self to
]

{ #category : 'pov' }
RTRoad >> povTraffic [

	<pov>
	^ CMPointOfView
		  color: (Color fromHexString: '4A5568')
		  size: self trafficSize
]

{ #category : 'pov' }
RTRoad >> povWear [

	<pov>
	^ CMPointOfView color: self wearColor size: 0.2
]

{ #category : 'pov' }
RTRoad >> povWearAndTraffic [

	<pov>
	^ CMPointOfView color: self wearColor size: self trafficSize
]

{ #category : 'actions' }
RTRoad >> recordUse [
	"A person has entered me."

	uses := uses + 1.
	wear := wear + self class wearPerUse
]

{ #category : 'actions' }
RTRoad >> repair [

	wear := 1
]

{ #category : 'pov' }
RTRoad >> trafficSize [
	"Grows with my uses, compared with the busiest road of the town, so main routes stand out at any time."

	| busiest |
	busiest := (self cormasModel @@ RTRoad collect: [ :road | road uses ])
		           max.
	^ 0.1 + (0.6 * self uses / (busiest max: 1))
]

{ #category : 'accessing' }
RTRoad >> uses [

	^ uses
]

{ #category : 'accessing' }
RTRoad >> wear [

	^ wear
]

{ #category : 'pov' }
RTRoad >> wearColor [
	"Green when unworn, turning red, and fully red from a wear of 2.5."

	^ CMColor red mixed: (self wear - 1 / 1.5 min: 1) with: CMColor green
]
