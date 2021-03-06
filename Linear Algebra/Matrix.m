//
//  Matrix.m
//  Linear Algebra
//
//  Created by ml on 2017/6/13.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import "Matrix.h"

@interface Matrix ()

@property (nonatomic, strong) NSMutableArray * array;
@end

@implementation Matrix

-(instancetype)init
{
    if (self = [super init])
    {
        _array = [NSMutableArray array];
        
        _columnIsCertain = NO;
        _row = 0;
        _column = -1;
        _currentColumn = -1;
    }
    return self;
}


- (NSInteger)getColumn
{
    return _column == -1?_currentColumn:_column;
}

#pragma mark add methods
-(BOOL)addObject:(id)object
{
    if (_column * _row > [_array count])
    {
        return NO;
    }
    [_array addObject:object];
    _currentColumn ++;
    if (_columnIsCertain && _currentColumn == _column)
    {
        return NO;
    }
    return YES;
}

- (void)newRow
{
    _columnIsCertain = YES;
    //第一行换行，确定矩阵的列数
    if (_column == -1)
    {
        if (_currentColumn == -1)
        {
            _column = 0;
            [_array addObject:@"0"];
        }
        else
        {
            _column = _currentColumn;
        }
    }
    else
    {
        //新增行时如果当前行未满，补全为0
        if (_currentColumn != _column)
        {
            for (int i = 0; i < _column - _currentColumn; i ++)
            {
                [_array addObject:@"0"];
            }
        } 
    }
    
    
    _currentColumn = -1;
    _row ++;
}

- (void)setDataSource:(NSMutableArray *)datasource
{
    _array = datasource;
}

#pragma mark  delete methods
- (id)deleteObject
{
    NSMutableArray * res = [NSMutableArray array];
    //空矩阵
    if (_array.count == 0)
    {
        return res;
    }
    //非空
    else
    {
        //当前行已无元素
        if (_currentColumn == -1)
        {
            _row --;
            _currentColumn = _column;
            if (_row == 0)
            {
                _columnIsCertain = NO;
                _column = -1;
            }
        }
        //当前行仍有元素
        else
        {
            _currentColumn --;
            if (_row == 0 && _column >= 0)
            {
                _column --;
            }
            NSString * temp = _array[_array.count - 1];
            BOOL isFloat = NO;
            for (int i = 0; i < [temp length]; i ++)
            {
                if ([[temp substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"."])
                {
                    isFloat = YES;
                }
                [res addObject:[temp substringWithRange:NSMakeRange(i, 1)]];
            }
            if (isFloat)
            {
                [res addObject:@"."];
            }
            [_array removeObjectAtIndex:_array.count - 1];
            return res;
        }
        return res;
    }
}

#pragma mark  get methods
- (id)getObjectAtRow:(NSInteger)row Column:(NSInteger)column
{
    return [self getObjectAtRow:row Column:column NoneValue:@"0"];
}

- (id)getObjectAtRow:(NSInteger)row Column:(NSInteger)column NoneValue:(NSString *)str
{
    NSInteger c = _column == -1?_currentColumn:_column;
    NSInteger index = row * (c + 1) + column;
    
    if (_array.count > index)
    {
        return _array[index];
    }
    return str;
}

- (NSInteger)getRealColumn
{
    return _column == -1?_currentColumn:_column;
}

#pragma mark  others
- (void)log
{
    NSInteger c = _column == -1?_currentColumn:_column;
    NSLog(@"row is %ld, column is %ld, array is %@", (long)_row, (long)c, _array);
    
    NSLog(@"--------");
    for (int i = 0; i <= _row; i++)
    {
        NSMutableString * str = [NSMutableString string];
        for (int j = 0; j <= c; j ++)
        {
            NSInteger index = i * (c + 1) + j;
            
            if (_array.count > index)
            {
                [str appendString:[NSString stringWithFormat:@"%@ ",_array[index]]];
            }
        }
        NSLog(@"%@",str);
    }
    NSLog(@"---------");
}

- (BOOL)isFull
{
    return (_columnIsCertain && ((_row + 1) * (_column + 1) == [_array count]));
}

- (BOOL)isTransposed
{
    return (_columnIsCertain && ((_row + 1) * (_column + 1) == [_array count])) || (!_columnIsCertain && _currentColumn >= 0);
}

- (void)transpose
{
    for (int i = 0; i < ([self getRealColumn] + 1) * (_row + 1); i ++)
    {
        NSInteger next = [self getNextObjectAtIndex:i Row:_row + 1 Column:[self getRealColumn] + 1];
        while(next > i)
            next = [self getNextObjectAtIndex:next Row:_row + 1 Column:[self getRealColumn] + 1];
        if(next == i)  // 处理当前环
            [self moveObjectAtIndex:i Row:_row + 1 Column:[self getRealColumn] + 1];
    }
    
    NSInteger temp = self.column;
    self.column = self.row;
    self.row = temp == -1?_currentColumn:temp;
    self.currentColumn = self.column;
    self.columnIsCertain = (self.row != 0);
}


- (void)moveObjectAtIndex:(NSInteger)index Row:(NSInteger)row Column:(NSInteger)column
{
    NSString * temp = _array[index];
    NSInteger currentIndex = index;
    NSInteger previousIndex = [self getPreviousObjectAtIndex:currentIndex Row:row Column:column];
    while (previousIndex != index)
    {
        _array[currentIndex] = _array[previousIndex];
        currentIndex = previousIndex;
        previousIndex = [self getPreviousObjectAtIndex:currentIndex Row:row Column:column];
    }
    _array[currentIndex] = temp;
}

- (NSInteger)getNextObjectAtIndex:(NSInteger)index Row:(NSInteger)row Column:(NSInteger)column
{
    return (index%column)*row + index/column;
}

- (NSInteger)getPreviousObjectAtIndex:(NSInteger)index Row:(NSInteger)row Column:(NSInteger)column
{
    return (index%row)*column + index/row;
}
@end
