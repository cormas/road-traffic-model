"
I am a network of roads, and what streets and the town have in common: how worn and how busy my roads are on average, and a point of view that shows it. A road in me then looks like an average road of mine, so all of my roads look the same.

## Responsibility:

- Answer the mean wear and the mean uses of all my roads.
- Show them in the same colours and widths as a single road.

## Collaborators:

- `RTRoad`: my roads, which know their wear, their uses and the colour of any wear.
- `RTRoadTrafficModel`: knows the width of a road with any number of uses.
- `RTStreet` and `RTTown`: my subclasses.

## Public API and Key Messages

- `meanWear` answers the average wear of my roads, or the wear of a new road if I have none.
- `meanUses` answers the average uses of my roads, or 0 if I have none.
- `povWearAndTraffic` shows both. Select it to compare streets, or to see how the whole town is doing.

```
RTStreet activePovSelector: #povWearAndTraffic.
model town members first meanWear
```
"
Class {
	#name : 'RTRoadNetwork',
	#superclass : 'CMNetwork',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTRoadNetwork >> meanUses [
	"No uses when I have no roads, so that I look quiet"

	self links ifEmpty: [ ^ 0 ].
	^ (self links collect: [ :road | road uses ]) average
]

{ #category : 'wear' }
RTRoadNetwork >> meanWear [
	"The wear of a new road when I have no roads, so that I look unworn"

	self links ifEmpty: [ ^ 1 ].
	^ (self links collect: [ :road | road wear ]) average
]

{ #category : 'pov' }
RTRoadNetwork >> povWearAndTraffic [
	"All my roads look like a single road with my mean wear and my mean uses"

	<pov>
	^ CMPointOfView
		  color: (RTRoad colorForWear: self meanWear)
		  size: (self cormasModel sizeForUses: self meanUses)
]
