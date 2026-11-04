"
I connect a person to the plot where they live.

## Responsibility:

- Tell a person where their home is.
- Show that connection as a line when my point of view is selected. The model hides me when it creates the town, because many of these lines would hide the roads.

## Collaborators:

- `RTPerson`: my `from` end.
- `RTPlot`: my `to` end.

## Public API and Key Messages

```
model newEntity: RTHomeLink from: person to: plot.
person nextEntitiesLinkedBy: RTHomeLink
```

"
Class {
	#name : 'RTHomeLink',
	#superclass : 'CMLink',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'pov' }
RTHomeLink >> pov [

	<pov>
	^ CMPointOfView color: CMColor orange size: 0.1
]
