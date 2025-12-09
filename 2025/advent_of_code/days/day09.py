from advent_of_code.infra import should_be
from shapely import Point, Polygon, box


def point_from_str(v: str) -> Point:
    x,y = [int(v) for v in v.split(',')]
    return Point(x, y)

def area(p1: Point, p2: Point) -> Polygon:
    return box(min(p1.x, p2.x), min(p1.y, p2.y), max(p1.x, p2.x), max(p1.y, p2.y))

def inclusive_area(p: Polygon):
    minx, miny, maxx, maxy = p.bounds
    return int(((maxx - minx) + 1) * ((maxy - miny) + 1))

@should_be(4748985168)
def part1(data: str) -> int:
    points = [point_from_str(c) for c in data.splitlines()]
    best_rect = box(0,0,0,0)
    for i, p1 in enumerate(points):
        for p2 in points[i + 1:]:
            rect = area(p1, p2)
            if inclusive_area(best_rect) < inclusive_area(rect):
                best_rect = rect

    return inclusive_area(best_rect)

@should_be(1550760868)
def part2(data: str) -> int:
    points = [point_from_str(c) for c in data.splitlines()]
    polygon = Polygon(points)
    best_rect = Polygon([])
    for i, p1 in enumerate(points):
        for p2 in points[i + 1:]:
            rect = area(p1, p2)
            if rect.area > best_rect.area and polygon.contains(rect):
                best_rect = rect

    return inclusive_area(best_rect)
