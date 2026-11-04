"
I am a plot of land in the town of the road traffic model. Some of the plots where roads meet are places where people live or work.

## Responsibility:

- Be a place that roads can join and that people can stand on.
- Know whether I am land, residential or industrial, and show it.
- Find the road to take from here towards another plot.

## Collaborators:

- `RTRoadTrafficModel`: creates me as part of its grid and tells me what I am.
- `RTRoad`: joins me to other plots.

## Public API and Key Messages

- `beResidential` and `beIndustrial` tell me what I am.
- `isResidential` and `isIndustrial` answer it.
- `cheapestRoadTo:` answers the first road of the cheapest route to another plot.

Get all plots from the model:

```
model @@ RTPlot
```

## Internal Representation

- `kind`: `#land`, `#residential` or `#industrial`.

"
Class {
	#name : 'RTPlot',
	#superclass : 'CMCell',
	#instVars : [
		'kind'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTPlot >> beIndustrial [

	kind := #industrial
]

{ #category : 'accessing' }
RTPlot >> beResidential [

	kind := #residential
]

{ #category : 'routes' }
RTPlot >> cheapestRoadTo: aPlot [
	"Answer the road to take from here on the cheapest route to aPlot, using Dijkstra's algorithm: always continue from the cheapest plot reached so far, until that plot is aPlot. It follows only roads, in the directions they allow, and compares their costs at this moment."

	| costs firstRoads frontier |
	costs := Dictionary new.
	firstRoads := Dictionary new.
	frontier := OrderedCollection with: self.
	costs at: self put: 0.
	[ frontier isEmpty ] whileFalse: [
			| plot |
			plot := frontier detectMin: [ :each | costs at: each ].
			frontier remove: plot.
			plot = aPlot ifTrue: [ ^ firstRoads at: aPlot ].
			(plot outgoingLinksOfClass: RTRoad) do: [ :road |
					| next cost |
					next := road otherEndOf: plot.
					cost := (costs at: plot) + road cost.
					cost < (costs at: next ifAbsent: [ Float infinity ]) ifTrue: [
							(costs includesKey: next) ifFalse: [ frontier add: next ].
							costs at: next put: cost.
							firstRoads
								at: next
								put: (firstRoads at: plot ifAbsent: [ road ]) ] ] ].
	self error: 'No route from this plot to the other plot'
]

{ #category : 'initialization' }
RTPlot >> initialize [

	super initialize.
	kind := #land
]

{ #category : 'testing' }
RTPlot >> isIndustrial [

	^ kind = #industrial
]

{ #category : 'testing' }
RTPlot >> isResidential [

	^ kind = #residential
]

{ #category : 'pov' }
RTPlot >> kindColor [

	self isResidential ifTrue: [ ^ CMColor orange ].
	self isIndustrial ifTrue: [ ^ CMColor blue ].
	^ CMColor paleTan
]

{ #category : 'pov' }
RTPlot >> pov [

	<pov>
	^ (CMPointOfView color: self kindColor)
		  borderWidth: 0;
		  yourself
]
