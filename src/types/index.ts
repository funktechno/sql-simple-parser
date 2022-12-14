export interface DatabaseModel {
  TableList: TableModel[];
  Dialect: string;
  ForeignKeyList: ForeignKeyModel[];
  PrimaryKeyList: PrimaryKeyModel[];
}

export interface TableModel {
  Name: string;
  Properties: PropertyModel[];
}

export interface PropertyModel {
  Name: string;
  Value?: string;
  ColumnProperties: string;
  TableName: string;
  ForeignKey: ForeignKeyModel[];
  IsPrimaryKey: boolean;
  IsForeignKey: boolean;
}

export interface ForeignKeyModel {
  PrimaryKeyName: string;
  ReferencesPropertyName: any;
  PrimaryKeyTableName: string;
  ReferencesTableName: string;
  IsDestination: boolean;
}

export interface PrimaryKeyModel {
  PrimaryKeyName: string;
  PrimaryKeyTableName: string;
}

export interface ColumnQuantifiers {
  Start: string;
  End: string;
}
