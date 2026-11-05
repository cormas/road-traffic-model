"
I am a network of roads, and what streets and the town have in common: how worn my roads are on average, and a point of view that shows it. A road in me then shows my wear instead of its own, as one colour for all of my roads.

## Responsibility:

- Answer the mean wear of all my roads.
- Show that wear in the same colours as a single road.

## Collaborators:

- `RTRoad`: my roads, which know their wear and the colour of any wear.
- `RTStreet` and `RTTown`: my subclasses.

## Public API and Key Messages

- `meanWear` answers the average wear of my roads, or the wear of a new road if I have none.
- `povWear` shows that wear. Select it to compare streets, or to see how the whole town is doing.

```
RTStreet activePovSelector: #povWear.
model town members first meanWear
```
"
Class {
	#name : 'RTRoadNetwork',
	#superclass : 'CMNetwork',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'wear' }
RTRoadNetwork >> meanWear [
	"The wear of a new road when I have no roads, so that I look unworn"

	self links ifEmpty: [ ^ 1 ].
	^ (self links collect: [ :road | road wear ]) average
]

{ #category : 'pov' }
RTRoadNetwork >> povWear [
	"All my roads show my mean wear as one color, in the colors of a single road"

	<pov>
	^ CMPointOfView color: (RTRoad colorForWear: self meanWear) size: 0.2
]
