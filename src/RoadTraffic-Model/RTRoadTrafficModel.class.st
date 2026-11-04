"
I am a town where people commute along a network of roads. My story comes from the Road Traffic tutorial of GAMA, adapted to the discrete grid of Cormas.

## Responsibility:

- Create the town on a grid of plots.

## Collaborators:

- `RTPlot`: the cells of my grid.

## Public API and Key Messages

- `initTown` creates the town.

Run me through a simulation, as any other Cormas model:

```
model := RTRoadTrafficModel new.
(CMSimulation for: model)
	activeInitSelector: #initTown;
	initializeSimulation.
model @@ RTPlot
```

"
Class {
	#name : 'RTRoadTrafficModel',
	#superclass : 'CMModel',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTRoadTrafficModel class >> modelName [

	^ 'Road Traffic'
]

{ #category : 'init' }
RTRoadTrafficModel >> initTown [

	<init>
	self
		createGridNumberOfRows: 50
		numberOfColumns: 50
		neighbourhood: 8
		closed: true
]
