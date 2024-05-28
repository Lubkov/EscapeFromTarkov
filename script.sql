CREATE TABLE Point (
  ID INTEGER PRIMARY KEY,
  X INTEGER NOT NULL,
  Y INTEGER NOT NULL  
);

CREATE TABLE LocalMap (
  ID INTEGER PRIMARY KEY,
  Name CHAR(64) NOT NULL,
  LeftID INTEGER NOT NULL,
  RightID INTEGER NOT NULL,
  Picture BINARY,  
  FOREIGN KEY(LeftID) REFERENCES Point(ID),
  FOREIGN KEY(RightID) REFERENCES Point(ID)
);

CREATE TRIGGER TR_LocalMap_Delete
AFTER DELETE ON LocalMap
FOR EACH ROW
BEGIN
    DELETE FROM Point WHERE ID in (OLD.LeftID, OLD.RightID);
END;

CREATE TABLE MapLevel (
  ID INTEGER PRIMARY KEY,
  MapID INTEGER NOT NULL,
  Level INTEGER NOT NULL,
  Name CHAR(64) NOT NULL,
  Picture BINARY,
  FOREIGN KEY(MapID) REFERENCES LocalMap(ID) ON DELETE CASCADE
);

CREATE TABLE MapTag (
  ID INTEGER PRIMARY KEY,
  MapID INTEGER NOT NULL,
  Name CHAR(64) NOT NULL,
  Kind INTEGER NOT NULL,
  Position INTEGER NOT NULL,
  FOREIGN KEY(MapID) REFERENCES LocalMap(ID) ON DELETE CASCADE,
  FOREIGN KEY(Position) REFERENCES Point(ID)
);

CREATE TRIGGER TR_MapTag_Delete
AFTER DELETE ON MapTag
FOR EACH ROW
BEGIN
    DELETE FROM Point WHERE ID = OLD.Position;
END;


