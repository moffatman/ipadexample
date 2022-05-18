import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class _Pointer {
	final Color color;
	Offset location;
	final bool isHover;
	PointerPanZoomUpdateEvent? panZoomUpdateEvent;
	_Pointer({
		required this.color,
		required this.location,
		required this.isHover
	});

	@override
	String toString() => '_Pointer(color: $color, location: $location, isHover: $isHover)';
}

class PointerOverlay extends StatefulWidget {
	final Widget child;
	const PointerOverlay({
		required this.child,
		Key? key
	}) : super(key: key);

	@override
	createState() => _PointerOverlayState();
}

class _PointerOverlayPainter extends CustomPainter {
	final Iterable<_Pointer> pointers;
	const _PointerOverlayPainter({
		required this.pointers
	});
	
	@override
	void paint(Canvas canvas, Size size) {
		for (final pointer in pointers) {
			if (pointer.panZoomUpdateEvent != null) {
				final loc = pointer.location + pointer.panZoomUpdateEvent!.pan;
				final rad = pointer.panZoomUpdateEvent!.rotation;
				final scale = pointer.panZoomUpdateEvent!.scale;
				canvas.drawLine(pointer.location, loc, Paint()..color = pointer.color.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth=15);
				final paint = Paint()..color = pointer.color.withOpacity(0.9)..style = PaintingStyle.stroke..strokeWidth=(15 * scale)..strokeCap=StrokeCap.round;
				canvas.drawLine(loc, loc + Offset.fromDirection(rad, 30 * scale), paint);
				canvas.drawLine(loc, loc + Offset.fromDirection(rad + (pi*0.5), 30 * scale), paint);
				canvas.drawLine(loc, loc + Offset.fromDirection(rad + pi, 30 * scale), paint);
				canvas.drawLine(loc, loc + Offset.fromDirection(rad + (pi*1.5), 30 * scale), paint);
			}
			else {
				canvas.drawCircle(
					pointer.location,
					pointer.isHover ? 15 : 25,
					Paint()..color = pointer.color.withOpacity(pointer.isHover ? 0.3 : 0.9)
									..style = PaintingStyle.fill
				);
			}
		}
	}
	
	@override
	bool shouldRepaint(_PointerOverlayPainter oldDelegate) {
		return true;
	}
}

class _PointerOverlayState extends State<PointerOverlay> {
	final Map<int, _Pointer> pointers = {};

	final _r = Random();
	Color _randomColor() => Color.fromARGB(255, _r.nextInt(256), _r.nextInt(256), _r.nextInt(256));

	@override
	Widget build(BuildContext context) {
		return MouseRegion(
			onEnter: (e) {
				pointers[e.pointer] = _Pointer(
					color: _randomColor(),
					location: e.localPosition,
					isHover: true
				);
				setState(() {});
			},
			onExit: (e) {
				pointers.remove(e.pointer);
				setState(() {});
			},
			child: Listener(
				onPointerDown: (e) {
					pointers[e.pointer] = _Pointer(
						color: _randomColor(),
						location: e.localPosition,
						isHover: false
					);
					setState(() {});
				},
				onPointerMove: (e) {
					pointers[e.pointer]?.location = e.localPosition;
					setState(() {});
				},
				onPointerUp: (e) {
					pointers.remove(e.pointer);
					setState(() {});
				},
				onPointerHover: (e) {
					pointers[e.pointer]?.location = e.localPosition;
					setState(() {});
				},
				onPointerCancel: (e) {
					pointers.remove(e.pointer);
					setState(() {});
				},
				onPointerPanZoomStart: (e) {
					pointers[e.pointer] = _Pointer(
						color: _randomColor(),
						location: e.localPosition,
						isHover: false
					);
					setState(() {});
				},
				onPointerPanZoomUpdate: (e) {
					pointers[e.pointer]?.location = e.localPosition;
					pointers[e.pointer]?.panZoomUpdateEvent = e;
					setState(() {});
				},
				onPointerPanZoomEnd: (e) {
					pointers.remove(e.pointer);
					setState(() {});
				},
				child: CustomPaint(
					foregroundPainter: _PointerOverlayPainter(
						pointers: pointers.values
					),
					child: widget.child
				)
			)
		);
	}
}