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

{ #category : 'examples' }
RTPlot class >> exampleResidentialPlot [

	<sampleInstance>
	^ RTRoadTrafficModel exampleTown residentialPlots first
]

{ #category : 'accessing' }
RTPlot >> beIndustrial [

	kind := #industrial
]

{ #category : 'accessing' }
RTPlot >> beResidential [

	kind := #residential
]

{ #category : 'routing' }
RTPlot >> cheapestRoadTo: aPlot [
	"Answer the road to take from here on the cheapest way to aPlot through the town, comparing the costs of the roads at this moment. It is an error if there is no way"

	^ (self wayTo: aPlot in: cormasModel town cost: [ :road | road cost ])
		  first
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
	"Deep colors on a paper-colored town: warm where people live and cool where they work. People use lighter shades of the same colors, to stand out on these plots."

	self isResidential ifTrue: [ ^ Color fromHexString: 'C8741A' ].
	self isIndustrial ifTrue: [ ^ Color fromHexString: '1034A6' ].
	^ Color fromHexString: 'F3EFE6'
]

{ #category : 'pov' }
RTPlot >> pov [

	<pov>
	^ (CMPointOfView color: self kindColor)
		  borderWidth: 0;
		  yourself
]
