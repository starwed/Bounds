// Generated by CoffeeScript 1.9.0
(function() {
  console.log("map tile incoming");

  Crafty.c("MapTile", {
    init: function() {
      return this;
    },
    setMapInfo: function(_at_map_c, _at_map_r, _at_tiledLevel, _at_mapTileType) {
      this.map_c = _at_map_c;
      this.map_r = _at_map_r;
      this.tiledLevel = _at_tiledLevel;
      this.mapTileType = _at_mapTileType;
      return this;
    },
    findRelativeTile: function(a, b) {
      var dc, dr, _ref, _ref1;
      if (typeof a === "string") {
        _ref = (function() {
          switch (a) {
            case "above":
              return [-1, 0];
            case "below":
              return [1, 0];
            case "right":
              return [0, 1];
            case "left":
              return [0, -1];
          }
        })(), dr = _ref[0], dc = _ref[1];
      } else {
        _ref1 = [a, b], dr = _ref1[0], dc = _ref1[1];
      }
      return this.tiledLevel.getTile(this.map_r + dr, this.map_c + dc);
    }
  });

  Crafty.c("TiledLevel", {
    makeTiles: function(ts, drawType) {
      var components, i, posx, posy, sMap, sName, tHeight, tName, tNum, tWidth, tsHeight, tsImage, tsProperties, tsWidth, xCount, yCount, _i, _ref;
      tsImage = ts.image, tNum = ts.firstgid, tsWidth = ts.imagewidth;
      tsHeight = ts.imageheight, tWidth = ts.tilewidth, tHeight = ts.tileheight;
      tsProperties = ts.tileproperties;
      xCount = tsWidth / tWidth | 0;
      yCount = tsHeight / tHeight | 0;
      sMap = {};
      for (i = _i = 0, _ref = yCount * xCount; _i < _ref; i = _i += 1) {
        posx = i % xCount;
        posy = i / xCount | 0;
        sName = "tileSprite" + tNum;
        tName = "tile" + tNum;
        sMap[sName] = [posx, posy];
        components = "2D, " + drawType + ", " + sName + ", MapTile";
        if (tsProperties) {
          if (tsProperties[tNum - 1]) {
            if (tsProperties[tNum - 1]["components"]) {
              components += ", " + tsProperties[tNum - 1]["components"];
            }
          }
        }
        Crafty.c(tName, {
          comp: components,
          init: function() {
            this.addComponent(this.comp);
            return this;
          }
        });
        tNum++;
      }
      Crafty.sprite(tWidth, tHeight, tsImage, sMap);
      return null;
    },
    makeLayer: function(layer) {
      var i, lData, lHeight, lWidth, layerDetails, tDatum, tile, _i, _len;
      lData = layer.data, lWidth = layer.width, lHeight = layer.height;
      layerDetails = {
        tiles: [],
        width: lWidth,
        height: lHeight
      };
      for (i = _i = 0, _len = lData.length; _i < _len; i = ++_i) {
        tDatum = lData[i];
        if (tDatum) {
          tile = Crafty.e("tile" + tDatum);
          tile.x = (i % lWidth) * tile.w;
          tile.y = (i / lWidth | 0) * tile.h;
          tile.addComponent("MapTile");
          tile.setMapInfo(i % lWidth, i / lWidth | 0, this, tDatum);
          layerDetails.tiles[i] = tile;
        }
      }
      this._layerArray.push(layerDetails);
      return null;
    },
    tiledLevel: function(levelURL, drawType) {
      console.log("Starting things off!");
      console.log(levelURL);
      $.ajax({
        type: 'GET',
        url: levelURL,
        dataType: 'json',
        data: {},
        async: false,
        success: (function(_this) {
          return function(level) {
            var lLayers, ts, tsImages, tss;
            console.log("loaded " + levelURL);
            lLayers = level.layers, tss = level.tilesets;
            drawType = drawType != null ? drawType : "Canvas";
            tsImages = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = tss.length; _i < _len; _i++) {
                ts = tss[_i];
                _results.push(ts.image);
              }
              return _results;
            })();
            Crafty.load({
              "sprites": tsImages
            }, function() {
              var layer, _i, _j, _len, _len1;
              for (_i = 0, _len = tss.length; _i < _len; _i++) {
                ts = tss[_i];
                _this.makeTiles(ts, drawType);
              }
              for (_j = 0, _len1 = lLayers.length; _j < _len1; _j++) {
                layer = lLayers[_j];
                _this.makeLayer(layer);
              }
              _this.trigger("TiledLevelLoaded");
              return null;
            });
            return null;
          };
        })(this)
      });
      return this;
    },
    getTile: function(r, c, l) {
      var layer, tile;
      if (l == null) {
        l = 0;
      }
      layer = this._layerArray[l];
      if ((layer == null) || r < 0 || r >= layer.height || c < 0 || c >= layer.width) {
        return null;
      }
      tile = layer.tiles[c + r * layer.width];
      if (tile) {
        return tile;
      }
    },
    init: function() {
      return this._layerArray = [];
    }
  });

}).call(this);
