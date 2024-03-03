unit unitGlobals;

interface

const
  UnitOption: array[0..1,0..1] of string = (('Inches','Millimetres'), ('G20','G21'));
  PathOption: array[0..1,0..1] of string = (('Exact Stop','Constant Velocity'), ('G61','G64'));
  FeedOption: array[0..1,0..1] of string = (('Inverse Time','Units per Minute'), ('G93','G94'));

implementation

end.
