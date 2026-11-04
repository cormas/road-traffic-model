"
I am one straight segment of road between two plots. A street that bends is a chain of several of me.

## Responsibility:

- Connect two junctions of the town, which can be many cells apart.
- Know whether traffic may only go from my `from` end to my `to` end.

## Collaborators:

- `RTRoadTrafficModel`: creates me from its table of roads.
- `RTPlot`: my two ends.

## Public API and Key Messages

- `beOneWay` makes me one-way, from `from` to `to`.
- `isOneWay` and `isDirected` tell whether I am one-way.

```
road := model newEntity: RTRoad from: plotA to: plotB.
road beOneWay
```

## Internal Representation

- `oneWay`: a boolean, false until I am told otherwise.

"
Class {
	#name : 'RTRoad',
	#superclass : 'CMLink',
	#instVars : [
		'oneWay'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTRoad >> beOneWay [

	oneWay := true
]

{ #category : 'initialization' }
RTRoad >> initialize [

	super initialize.
	oneWay := false
]

{ #category : 'testing' }
RTRoad >> isDirected [

	^ self isOneWay
]

{ #category : 'testing' }
RTRoad >> isOneWay [

	^ oneWay
]

{ #category : 'pov' }
RTRoad >> pov [

	<pov>
	^ CMPointOfView size: 0.2
]
