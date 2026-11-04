"
I am a person who lives in one place in the town and works in another.

## Responsibility:

- Know my home and my workplace, through the links that connect me to them.

## Collaborators:

- `RTHomeLink` and `RTWorkLink`: connect me to the plots where I live and work.
- `RTPlot`: where I stand.

## Public API and Key Messages

- `home` answers the plot where I live.
- `workplace` answers the plot where I work.

```
person := model newEntity: RTPerson locatedAt: homePlot.
model newEntity: RTHomeLink from: person to: homePlot.
model newEntity: RTWorkLink from: person to: workPlot.
person home
```

"
Class {
	#name : 'RTPerson',
	#superclass : 'CMAgent',
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTPerson >> home [

	^ (self nextEntitiesLinkedBy: RTHomeLink) first
]

{ #category : 'accessing' }
RTPerson >> workplace [

	^ (self nextEntitiesLinkedBy: RTWorkLink) first
]
