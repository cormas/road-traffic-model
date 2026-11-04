"
I am a plot of land in the town of the road traffic model. Some of the plots where roads meet are places where people live or work.

## Responsibility:

- Be a place that roads can join and that people can stand on.
- Know whether I am land, residential or industrial, and show it.

## Collaborators:

- `RTRoadTrafficModel`: creates me as part of its grid and tells me what I am.
- `RTRoad`: joins me to other plots.

## Public API and Key Messages

- `beResidential` and `beIndustrial` tell me what I am.
- `isResidential` and `isIndustrial` answer it.

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
