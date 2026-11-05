"
I am a town where people commute along a network of roads. Roads wear out with use, which slows people down and pushes traffic onto other routes, and a council repairs the most worn roads each day. My story comes from the Road Traffic tutorial of GAMA (https://gama-platform.org/wiki/RoadTrafficModel), adapted to the discrete grid of Cormas.

## Responsibility:

- Create the town: a grid of plots and a network of roads drawn by hand in a table, grouped into streets, which together make up the town.
- Know which plots are residential and which are industrial.
- Create the people, each with a home and a workplace chosen at random.
- Keep time: a Cormas step is a substep of a day, and `stepOfDay` tells which one.
- Repair the most worn roads once a day.

## Collaborators:

- `RTPlot`: the cells of my grid.
- `RTRoad`: the links between plots that make up the network.
- `RTPerson`: the people of the town.
- `RTHomeLink` and `RTWorkLink`: connect people to their places. I hide these lines when I create the town, and selecting their point of view shows them.

## Public API and Key Messages

- `initTown` creates the town with two-way roads.
- `initTownWithOneWays` creates the same town and applies the one-way marks of the table.
- `stepAlongTheLine` and `stepWithMoveTowards` run one step, and differ only in how people walk along a road.
- `dayStep` holds what happens once a day. Both steps send it at the start of each day.
- `residentialPlots` and `industrialPlots` answer the places where people live and work.
- `stepOfDay` answers the step of the current day.
- `numberOfPeople` and `repairsPerDay` are parameters, and so is `wearPerUse` on `RTRoad`.
- `meanWear`, `maxWear`, `peopleAtHome`, `peopleAtWork` and `peopleOnTheRoad` are the charts.

Open me in a simulation window with `RTRoadTrafficModel scriptOpenSimulation`, or run me from code:

```
model := RTRoadTrafficModel new.
simulation := CMSimulation for: model.
simulation
	activeInitSelector: #initTown;
	activeControlSelector: #stepAlongTheLine;
	initializeSimulation.
simulation runStep.
model peopleOnTheRoad
```

## Internal Representation

- `numberOfPeople`: an integer.
- `repairsPerDay`: an integer.

### Implementation Points

Many models work in days, months or years made of smaller steps, and Cormas runs one step at a time. So `stepOfDay` derives the day from the current time step, and each control method sends `dayStep` when `isStartOfDay` is true. The view and charts still update at every step, so people are seen walking.

"
Class {
	#name : 'RTRoadTrafficModel',
	#superclass : 'CMModel',
	#instVars : [
		'numberOfPeople',
		'repairsPerDay'
	],
	#category : 'RoadTraffic-Model',
	#package : 'RoadTraffic-Model'
}

{ #category : 'accessing' }
RTRoadTrafficModel class >> aboutThisModel [

	^ 'People commute between home and work along a network of roads drawn on a 50x50 grid. Each road is a link between two plots. Roads wear out with use, which slows people down and pushes traffic onto other routes, and the council repairs the most worn roads each day. A day has 100 steps. Adapted to the grid of Cormas from the Road Traffic tutorial of GAMA.'
]

{ #category : 'examples' }
RTRoadTrafficModel class >> exampleTown [

	<sampleInstance>
	| model |
	model := self new.
	(CMSimulation for: model)
		activeInitSelector: #initTown;
		activeControlSelector: #stepAlongTheLine;
		initializeSimulation.
	^ model
]

{ #category : 'accessing' }
RTRoadTrafficModel class >> modelName [

	^ 'Road Traffic'
]

{ #category : 'examples' }
RTRoadTrafficModel class >> scriptOpenSimulation [

	<script>
	^ CMSimulationApplication new
		  cormasModel: self new;
		  run
]

{ #category : 'init' }
RTRoadTrafficModel >> createPeople [
	"Everyone starts at home. The lines from people to their places are hidden, because so many of them would hide the roads."

	| homes workplaces |
	homes := self residentialPlots.
	workplaces := self industrialPlots.
	self numberOfPeople timesRepeat: [
			| home person |
			home := self selectRandomlyFrom: homes.
			person := self newEntity: RTPerson locatedAt: home.
			self newEntity: RTHomeLink from: person to: home.
			self
				newEntity: RTWorkLink
				from: person
				to: (self selectRandomlyFrom: workplaces) ].
	RTHomeLink activePovSelector: #povInvisible.
	RTWorkLink activePovSelector: #povInvisible
]

{ #category : 'init' }
RTRoadTrafficModel >> createRoads [
	"The town holds the streets, and each street holds its roads"

	| town |
	town := self newEntity: RTTown.
	self streetTable do: [ :row |
			| street |
			street := self newEntity: RTStreet.
			street name: row first.
			row allButFirst do: [ :road |
					street add: (self
							 newEntity: RTRoad
							 from: (self cellAt: road first at: road second)
							 to: (self cellAt: road third at: road fourth)) ].
			town add: street ].
	RTRoad activePovSelector: #povWearAndTraffic
]

{ #category : 'init' }
RTRoadTrafficModel >> createTown [

	self
		createGridNumberOfRows: 50
		numberOfColumns: 50
		neighbourhood: 8
		closed: true.
	self createRoads.
	self markPlaces.
	self createPeople
]

{ #category : 'control' }
RTRoadTrafficModel >> dayStep [
	"What happens once a day, as opposed to at every step. The council repairs the most worn roads."

	((self @@ RTRoad sorted: [ :road :other | road wear > other wear ])
		 first: self repairsPerDay) do: [ :road | road repair ]
]

{ #category : 'map' }
RTRoadTrafficModel >> industrialPlaces [
	"The plots where people work, as row and column."

	^ #( #( 38 45 ) #( 46 27 ) #( 17 47 ) )
]

{ #category : 'accessing' }
RTRoadTrafficModel >> industrialPlots [

	^ self @@ RTPlot select: [ :plot | plot isIndustrial ]
]

{ #category : 'init' }
RTRoadTrafficModel >> initTown [

	<init>
	self createTown
]

{ #category : 'init' }
RTRoadTrafficModel >> initTownWithOneWays [

	<init>
	self createTown.
	self makeMarkedRoadsOneWay
]

{ #category : 'time' }
RTRoadTrafficModel >> isStartOfDay [

	^ self stepOfDay = 1
]

{ #category : 'init' }
RTRoadTrafficModel >> makeMarkedRoadsOneWay [
	"Roads are created in the order of the table."

	self @@ RTRoad
		with: self roadTable
		do: [ :road :row | row size = 5 ifTrue: [ road beOneWay ] ]
]

{ #category : 'init' }
RTRoadTrafficModel >> markPlaces [

	self residentialPlaces do: [ :place |
		(self cellAt: place first at: place second) beResidential ].
	self industrialPlaces do: [ :place |
		(self cellAt: place first at: place second) beIndustrial ]
]

{ #category : 'probes' }
RTRoadTrafficModel >> maxWear [

	<probeNamed: 'Max wear' color: 'B90E0A'>
	^ (self @@ RTRoad collect: [ :road | road wear ]) max
]

{ #category : 'probes' }
RTRoadTrafficModel >> meanWear [

	<probeNamed: 'Mean wear' color: '5C612B'>
	^ self town meanWear
]

{ #category : 'parameters' }
RTRoadTrafficModel >> numberOfPeople [

	<parameterIntegerMin: 1 max: 500 default: 30>
	^ numberOfPeople
]

{ #category : 'parameters' }
RTRoadTrafficModel >> numberOfPeople: aNumber [

	numberOfPeople := aNumber
]

{ #category : 'probes' }
RTRoadTrafficModel >> peopleAtHome [

	<probeNamed: 'People at home' color: 'FFB000'>
	^ self @@ RTPerson count: [ :person | person isAtHome ]
]

{ #category : 'probes' }
RTRoadTrafficModel >> peopleAtWork [

	<probeNamed: 'People at work' color: '3AA0F2'>
	^ self @@ RTPerson count: [ :person | person isAtWork ]
]

{ #category : 'probes' }
RTRoadTrafficModel >> peopleOnTheRoad [

	<probeNamed: 'People on the road' color: '4A5568'>
	^ self @@ RTPerson count: [ :person | person isOnRoad ]
]

{ #category : 'parameters' }
RTRoadTrafficModel >> repairsPerDay [

	<parameterIntegerMin: 0 max: 43 default: 5>
	^ repairsPerDay
]

{ #category : 'parameters' }
RTRoadTrafficModel >> repairsPerDay: aNumber [

	repairsPerDay := aNumber
]

{ #category : 'map' }
RTRoadTrafficModel >> residentialPlaces [
	"The plots where people live, as row and column."

	^ #( #( 6 8 ) #( 4 22 ) #( 18 3 ) #( 35 4 ) #( 43 10 ) #( 5 38 )
	     #( 46 22 ) #( 25 25 ) )
]

{ #category : 'accessing' }
RTRoadTrafficModel >> residentialPlots [

	^ self @@ RTPlot select: [ :plot | plot isResidential ]
]

{ #category : 'map' }
RTRoadTrafficModel >> roadTable [
	"The roads of all the streets, in the order they are created"

	^ self streetTable flatCollect: [ :street | street allButFirst ]
]

{ #category : 'control' }
RTRoadTrafficModel >> stepAlongTheLine [

	<control>
	self isStartOfDay ifTrue: [ self dayStep ].
	self @@ RTPerson do: [ :person | person walkAlongTheLine ]
]

{ #category : 'time' }
RTRoadTrafficModel >> stepOfDay [
	"A Cormas step is a substep of my day. The current time step grows for ever, so the step of the day, from 1 to stepsPerDay, comes from it. Months or years would work the same way."

	^ self currentTimeStep - 1 \\ self stepsPerDay + 1
]

{ #category : 'control' }
RTRoadTrafficModel >> stepWithMoveTowards [

	<control>
	self isStartOfDay ifTrue: [ self dayStep ].
	self @@ RTPerson do: [ :person | person walkWithMoveTowards ]
]

{ #category : 'time' }
RTRoadTrafficModel >> stepsPerDay [

	^ 100
]

{ #category : 'map' }
RTRoadTrafficModel >> streetTable [
	"The streets of the town: a name, then one row per straight road: from row, from column, to row, to column. A street that bends is several rows that share a plot. A last #oneWay makes the road one-way from its first plot to its second, when the town uses one-way roads. Change a row to move a road."

	^ #( #( 'Ring Road' #( 18 22 19 30 ) #( 19 30 25 33 )
	        #( 25 33 31 29 ) #( 31 29 32 21 ) #( 32 21 26 17 )
	        #( 26 17 18 22 ) )
	     #( 'Market Square' #( 25 25 18 22 ) #( 25 25 25 33 #oneWay )
	        #( 25 25 32 21 ) )
	     #( 'North Road' #( 18 22 11 19 ) #( 11 19 4 22 ) )
	     #( 'Hill Road' #( 19 30 12 33 ) #( 12 33 5 38 ) #( 5 38 3 46 ) )
	     #( 'Chapel Lane' #( 11 19 9 26 ) #( 9 26 12 33 #oneWay )
	        #( 9 26 4 22 ) )
	     #( 'East Road' #( 25 33 22 41 ) #( 22 41 17 47 ) )
	     #( 'Canal Street' #( 12 33 15 39 ) #( 15 39 22 41 #oneWay )
	        #( 15 39 17 47 ) )
	     #( 'Harbour Road' #( 31 29 33 38 ) #( 33 38 38 45 ) )
	     #( 'South Road' #( 31 29 39 31 ) #( 39 31 46 27 ) )
	     #( 'Bridge Street' #( 33 38 39 31 ) #( 41 25 39 31 #oneWay ) )
	     #( 'Mill Lane' #( 41 25 39 18 ) #( 41 25 46 27 ) )
	     #( 'West Road' #( 32 21 39 18 ) #( 39 18 46 22 )
	        #( 39 18 43 10 ) )
	     #( 'Fort Road' #( 26 17 22 10 ) #( 22 10 18 3 ) )
	     #( 'Old Road' #( 26 17 30 10 ) #( 30 10 35 4 ) )
	     #( 'Cross Lane' #( 22 10 30 10 #oneWay )
	        #( 30 10 39 18 ) )
	     #( 'Coast Lane' #( 35 4 43 10 ) )
	     #( 'Station Road' #( 18 22 13 12 ) #( 13 12 6 8 ) #( 13 12 22 10 ) ) )
]

{ #category : 'accessing' }
RTRoadTrafficModel >> town [
	"There is one town, created with the roads"

	^ (self @@ RTTown) first
]
