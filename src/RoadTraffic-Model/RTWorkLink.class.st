"
I connect a person to the plot where they work.

## Responsibility:

- Tell a person where their workplace is.
- Show that connection as a line when my point of view is selected. The model hides me when it creates the town, because many of these lines would hide the roads.

## Collaborators:

- `RTPerson`: my `from` end.
- `RTPlot`: my `to` end.

## Public API and Key Messages

```
model newEntity: RTWorkLink from: person to: plot.
person nextEntitiesLinkedBy: RTWorkLink
```

"
Class {
	#name : 'RTWorkLink',
	#superclass : 'CMLink',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'examples' }
RTWorkLink class >> exampleWorkLink [

	<sampleInstance>
	^ (RTRoadTrafficModel exampleTown @@ self) first
]

{ #category : 'pov' }
RTWorkLink >> pov [

	<pov>
	^ CMPointOfView color: RTPerson workColor size: 0.1
]
