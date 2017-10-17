<?xml version="1.0" encoding="utf-8" ?>
<Configuration>
    <ViewDefinitions>

        <View>
            <Name>MyTools.OSInfo.Output.Thing</Name>
            <ViewSelectedBy>
                <TypeName>MyTools.OSInfo.Output.Thing</TypeName>
            </ViewSelectedBy>
 
             <TableControl>

                <TableHeaders>
                    <TableColumnHeader>
                        <Label>ComputerName</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>OS</Label>
                    </TableColumnHeader>
                    <TableColumnHeader>
                        <Label>SP</Label>
                        <Width>3</Width>
                    </TableColumnHeader>
                </TableHeaders>

                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem>
                                <PropertyName>ComputerName</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>OSVersion</PropertyName>
                            </TableColumnItem>
                            <TableColumnItem>
                                <PropertyName>SPVersion</PropertyName>
                            </TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                 </TableRowEntries>
                
            </TableControl>
 
        </View>

    </ViewDefinitions>
</Configuration>
