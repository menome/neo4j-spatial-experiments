import React from 'react'
import DeckGL, { HexagonLayer, IconLayer } from 'deck.gl'
import { StaticMap } from 'react-map-gl'
import neo4j from 'neo4j-driver/lib/browser/neo4j-web'

import IconClusterLayer from './icon-cluster-layer'
import iconAtlas from './location-icon-atlas.png'
import iconMapping from './location-icon-mapping.json'

const LIGHT_SETTINGS = {
  lightsPosition: [-0.144528, 49.739968, 8000, -3.807751, 54.104682, 8000],
  ambientRatio: 0.4,
  diffuseRatio: 0.6,
  specularRatio: 0.2,
  lightsStrength: [0.8, 0.0, 0.8, 0.0],
  numberOfLights: 2
};

const COLOR_RANGE = [
  [46, 254, 181],
  [1, 152, 189],
  [73, 227, 206]
];

const COLOR_GRANT = [
  [235, 30, 30],
  [242, 109, 249],
  [219, 48, 105]
]

const COLOR_CORNER = [
  [158, 169, 63],
  [118, 176, 65],
  [5, 74, 41]
]

const stopPropagation = evt => evt.stopPropagation();

const elevationScale = {min: 1, max: 20}

class App extends React.Component {

  constructor(props) {
  super(props)

  this.state = {
    mapboxAccessToken: 'YOUR TOKEN HERE',
    mapCenter: {
      longitude: -114.0708,
      latitude: 51.0486,
      minZoom: 5,
      maxZoom: 15,
      zoom: 13,
      // pitch: 0,
      // bearing: 0
      pitch: 40.5,
      bearing: -27.396674584323023,
    },
    elevationScale: elevationScale.min,
    hoveredItems: [],
    x: 0,
    y: 0,
    tenData: [],
    fourteenData: [],
    eigthteenData: [],
    data: [],
    buildingData: [],
    flipIconLayers: false,
    flipTenLayers: true,
    flipFourteenLayers: true,
    flipEighteenLayers: true,
  }

  this.driver = neo4j.driver(
    process.env.REACT_APP_NEO4J_URI,
    neo4j.auth.basic('neo4j','password'
     // process.env.REACT_APP_NEO4J_USER,
     // process.env.REACT_APP_NEO4J_PASSWORD
    ),
    { encrypted: true }
  )

this._onHover = this._onHover.bind(this)
this._renderhoveredItems = this._renderhoveredItems.bind(this)
this._closePopup = this._closePopup.bind(this)

}

_onHover(info) {
  const {x, y, object} = info;

  let hoveredItems = null;

  if (object) {
      hoveredItems = [object];
  }

  this.setState(prev => ({...prev, x, y, hoveredItems}))

}

_onPopupLoad(ref) {
   if (ref) {
     // React events are triggered after native events
     ref.addEventListener('wheel', stopPropagation);
   }
 }

 _closePopup() {
   this.setState({hoveredItems: null});
 }

_renderhoveredItems() {
    const {hoveredItems} = this.state;
    if (!hoveredItems) {
      return null;
    }

      return (

        <React.Fragment>
        <style jsx>{`
          .tooltip {
            background-color: #fafafa;
            position: absolute;
            top: 30px;
            z-index: 100;
          }
        `}</style>
        <div
          className="tooltip interactive"
          ref={this._onPopupLoad}
          onMouseLeave={this._closePopup}
        >
          {hoveredItems.map(({name, code, finishdate}) => {
            return (
              <div className="meow" key={name}>
                <h5>{name}</h5>
                <div>Code: {code || 'unknown'}</div>
                <div>Date: {finishdate}</div>
              </div>
            );
          })}
        </div>
        </React.Fragment>
      );

  }

componentDidMount () {
  this.fetch2010()
  this.fetch2014()
  this.fetch2018()
  this.fetchBuildings()
}


fetchBuildings = () => {
  const session = this.driver.session()

  session
    .run(
      // 2 find amenity types within the 1600 m boundary (could be expanded to all calgary amenities for dynamic classification)
      `match (space:Building )
        return space`
    )
    .then(result => {
      const meow = result.records.map(objectify)
      //const tenData = deckGlHexData(meow)
     //const data = deckGlData(meow)
      const buildingData=deckGlData(meow)
      this.setState(prev => ({...prev, buildingData}))
      session.close()
    })
    .catch(e => {
      console.log(e)
      session.close()
    })
}

fetch2010 = () => {
  const session = this.driver.session()

  session
    .run(
      // 2 find amenity types within the 1600 m boundary (could be expanded to all calgary amenities for dynamic classification)
      `
        match (space:PointOfInterest)-[]-(t:OSMTags) where exists (t.amenity) and t.amenity in ['marketplace','restaurant','nightclub','fast_food','pub','ice_cream','cafe','marketplace'] 
        and space.timestamp.year <=2010
        return space`
    )
    .then(result => {
      const meow = result.records.map(objectify)
      const tenData = deckGlHexData(meow)
      const data = deckGlData(meow)
      this.setState(prev => ({...prev, data, tenData}))
      session.close()
    })
    .catch(e => {
      console.log(e)
      session.close()
    })
}

fetch2014 = () => {
  const session = this.driver.session()

  session
    .run(
      `
      match (space:PointOfInterest)-[]-(t:OSMTags) where  exists (t.amenity) and t.amenity in ['marketplace','restaurant','nightclub','fast_food','pub','ice_cream','cafe','marketplace'] 
      and space.timestamp.year <=2014
      return space `
    )
    .then(result => {
      const meow = result.records.map(objectify)
      const fourteenData = deckGlHexData(meow)
      this.setState(prev => ({...prev, fourteenData}))
      session.close()
    })
    .catch(e => {
      console.log(e)
      session.close()
    })
}

fetch2018 = () => {
  const session = this.driver.session()

  session
    .run(
      `
      match (space:PointOfInterest)-[]-(t:OSMTags) where exists (t.amenity) and t.amenity in ['marketplace','restaurant','nightclub','fast_food','pub','ice_cream','cafe','marketplace'] 
      and space.timestamp.year <=2018
      return space`
    )
    .then(result => {
      const meow = result.records.map(objectify)
      const eigthteenData = deckGlHexData(meow)
      console.log(eigthteenData)
      this.setState(prev => ({...prev, eigthteenData}))
      session.close()
    })
    .catch(e => {
      console.log(e)
      session.close()
    })
}

_renderLayers() {
   const {upperPercentile = 100, coverage = 1, viewState, showCluster = true} = this.props

   const size = viewState ? Math.min(Math.pow(1.5, viewState.zoom - 10), 1) : 0.1;

const layer = showCluster
  ? new IconClusterLayer({
       id: 'icon-cluster-layer',
       data: this.state.buildingData,
       pickable: true,
       iconMapping: iconMapping,
       iconAtlas: iconAtlas,
       sizeScale: 40,
       getPosition: d => d.coordinates,
       getIcon: d => 'marker',
       getSize: d => 5,
       getColor: d => [Math.sqrt(d.exits), 140, 0],
       onHover: this._onHover,
       visible: this.state.flipIconLayers,
 }) : new IconLayer({
        id: 'icon-layer',
        data: this.state.buildingData,
        pickable: true,
        iconMapping: iconMapping,
        iconAtlas: iconAtlas,
        sizeScale: 40,
        getPosition: d => d.coordinates,
        getIcon: d => 'marker',
        getSize: size,
        getColor: d => [Math.sqrt(d.exits), 140, 0],
        onHover: this._onHover,
        visible: this.state.flipIconLayers,
  });
   return [
     new HexagonLayer({
       id: 'tenmap',
       colorRange : COLOR_RANGE,
       coverage,
       data: this.state.tenData,
       elevationRange: [0, 100],
       elevationScale: 20,
       extruded: true,
       getPosition: d => d,
       lightSettings: LIGHT_SETTINGS,
       onHover: this._onHover,
       opacity: 0.9,
       pickable: Boolean(this.props.onHover),
       radius: 90,
       visible: this.state.flipTenLayers,
       upperPercentile
     }),
     new HexagonLayer({
       id: 'fourteenmap',
       colorRange : COLOR_GRANT,
       coverage,
       data: this.state.fourteenData,
       elevationRange: [0, 100],
       elevationScale: 20,
       extruded: true,
       getPosition: d => d,
       lightSettings: LIGHT_SETTINGS,
       onHover: this._onHover,
       opacity: 0.09,
       pickable: Boolean(this.props.onHover),
       radius: 90,
       visible: this.state.flipFourteenLayers,
       upperPercentile
     }),
     new HexagonLayer({
       id: 'eighteenmap',
       colorRange : COLOR_CORNER,
       coverage,
       data: this.state.eigthteenData,
       elevationRange: [0, 100],
       elevationScale: 20,
       extruded: true,
       getPosition: d => d,
       lightSettings: LIGHT_SETTINGS,
       onHover: this._onHover,
       opacity: 0.09,
       pickable: Boolean(this.props.onHover),
       radius: 30,
       visible: this.state.flipEighteenLayers,
       upperPercentile
     }),
    layer
  ];
 }

  render() {
    const {viewState, controller = true} = this.props;

    return (
      <React.Fragment>
      <style jsx>{`
        hello {
          background-color: #fafafa;
          z-index: 100;
        }

        #app-wrapper {
  height: 100%;
  position: absolute;
  width: 100%;
}

#app-toolbar {
  background: rgba(0,0,0,.75);
  box-shadow: 0 1px 5px rgba(0,0,0,.1);
  color: #fff;
  position: fixed;
  top: 0px;
  width: 100%;
  z-index: 1;
}

#app-maparea {
  border-right: 1px solid #d7d7d7;
  position: fixed;
  top: 0px;
  width: 100%;
  z-index: 0;
  height: 100%;
}
      `}</style>
<div id="app-wrapper">
    <div id="app-maparea">
    <DeckGL
      initialViewState={this.state.mapCenter}
      controller={controller}
      layers={this._renderLayers()}
      viewState={viewState}
    >
      <StaticMap
          reuseMaps
          mapStyle="mapbox://styles/mapbox/dark-v9"
          preventStyleDiffing={true}
          mapboxApiAccessToken={this.state.mapboxAccessToken}
        />
        {this._renderhoveredItems}
    </DeckGL>
  </div>

  <div id="app-toolbar">
  <button className='hello' onClick={() => this.setState(prev => ({...prev, flipTenLayers: !prev.flipTenLayers}))}>2010</button>
  <button className='hello' onClick={() => this.setState(prev => ({...prev, flipFourteenLayers: !prev.flipFourteenLayers}))}>2014</button>
  <button className='hello' onClick={() => this.setState(prev => ({...prev, flipEighteenLayers: !prev.flipEighteenLayers}))}>2018</button>
  <button className='hello' onClick={() => this.setState(prev => ({...prev, flipIconLayers: !prev.flipIconLayers}))}>Buildings</button>

  </div>
</div>
      </React.Fragment>
    )
  }
}

function objectify (record) {
  const result = {}
  record._fields.map((field, idx) => {
    const key = record.keys[idx]
    if (field != null && typeof field === 'object' && field.toString() !== '[object Object]') {
      result[key] = field instanceof Array ? field.map(obj => obj.properties) : field.properties
    } else {
      result[key] = field
    }
  })
  return result
}

function deckGlData (records) {
const list = []
 records.map(space => list.push({name: space.space.Name, code: space.space.Code, coordinates: [Number(space.space.lon), Number(space.space.lat)]}))
 return list
}

function deckGlHexData (records) {
  return records.map(space => [Number(space.space.lon), Number(space.space.lat)])
}

export default App
