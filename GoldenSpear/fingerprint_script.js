/*
* fingerprintJS 0.5.0 - Fast browser fingerprint library
* https://github.com/Valve/fingerprintjs
* Copyright (c) 2013 Valentin Vasilyev (iamvalentin@gmail.com)
* Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
*/
/*jslint browser: true, indent: 2, maxerr: 50, maxlen: 120 */
(function (scope) {
	'use strict';

	var Fingerprint = function (options) {
		var nativeForEach, nativeMap;
		nativeForEach = Array.prototype.forEach;
		nativeMap = Array.prototype.map;

		this.each = function (obj, iterator, context) {
			if (obj === null) {
				return;
			}
			if (nativeForEach && obj.forEach === nativeForEach) {
				obj.forEach(iterator, context);
			} else if (obj.length === +obj.length) {
				for (var i = 0, l = obj.length; i < l; i++) {
					if (iterator.call(context, obj[i], i, obj) === {}) return;
				}
			} else {
				for (var key in obj) {
					if (obj.hasOwnProperty(key)) {
						if (iterator.call(context, obj[key], key, obj) === {}) return;
					}
				}
			}
		};

		this.map = function (obj, iterator, context) {
			var results = [];
			// Not using strict equality so that this acts as a
			// shortcut to checking for `null` and `undefined`.
			if (obj == null) return results;
			if (nativeMap && obj.map === nativeMap) return obj.map(iterator, context);
			this.each(obj, function (value, index, list) {
				results[results.length] = iterator.call(context, value, index, list);
			});
			return results;
		};

		if (typeof options == 'object') {
			this.hasher = options.hasher;
			this.screen_resolution = options.screen_resolution;
			this.canvas = options.canvas;
			this.ie_activex = options.ie_activex;
		} else if (typeof options == 'function') {
			this.hasher = options;
		}
	};

	Fingerprint.prototype = {
		get: function () {
			var keys = [];
			keys.push(navigator.userAgent);
			keys.push(navigator.language);
			keys.push(screen.colorDepth);
			if (this.screen_resolution) {
				var resolution = this.getScreenResolution();
				if (typeof resolution !== 'undefined') { // headless browsers, such as phantomjs
					keys.push(this.getScreenResolution().join('x'));
				}
			}
			keys.push(new Date().getTimezoneOffset());
			keys.push(this.hasSessionStorage());
			keys.push(this.hasLocalStorage());
			keys.push(!!window.indexedDB);
			keys.push(typeof (document.body.addBehavior));
			keys.push(typeof (window.openDatabase));
			keys.push(navigator.cpuClass);
			keys.push(navigator.platform);
			keys.push(navigator.doNotTrack);
			keys.push(this.getPluginsString());
			if (this.canvas && this.isCanvasSupported()) {
				keys.push(this.getCanvasFingerprint());
			}
			if (this.hasher) {
				return this.hasher(keys.join('###'), 31);
			} else {
				return this.murmurhash3_32_gc(keys.join('###'), 31);
			}
		},

		/**
		 * JS Implementation of MurmurHash3 (r136) (as of May 20, 2011)
		 * 
		 * @author <a href="mailto:gary.court@gmail.com">Gary Court</a>
		 * @see http://github.com/garycourt/murmurhash-js
		 * @author <a href="mailto:aappleby@gmail.com">Austin Appleby</a>
		 * @see http://sites.google.com/site/murmurhash/
		 * 
		 * @param {string} key ASCII only
		 * @param {number} seed Positive integer only
		 * @return {number} 32-bit positive integer hash 
		 */

		murmurhash3_32_gc: function (key, seed) {
			var remainder, bytes, h1, h1b, c1, c2, k1, i;

			remainder = key.length & 3; // key.length % 4
			bytes = key.length - remainder;
			h1 = seed;
			c1 = 0xcc9e2d51;
			c2 = 0x1b873593;
			i = 0;

			while (i < bytes) {
				k1 =
				  ((key.charCodeAt(i) & 0xff)) |
				  ((key.charCodeAt(++i) & 0xff) << 8) |
				  ((key.charCodeAt(++i) & 0xff) << 16) |
				  ((key.charCodeAt(++i) & 0xff) << 24);
				++i;

				k1 = ((((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16))) & 0xffffffff;
				k1 = (k1 << 15) | (k1 >>> 17);
				k1 = ((((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16))) & 0xffffffff;

				h1 ^= k1;
				h1 = (h1 << 13) | (h1 >>> 19);
				h1b = ((((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16))) & 0xffffffff;
				h1 = (((h1b & 0xffff) + 0x6b64) + ((((h1b >>> 16) + 0xe654) & 0xffff) << 16));
			}

			k1 = 0;

			switch (remainder) {
				case 3: k1 ^= (key.charCodeAt(i + 2) & 0xff) << 16;
				case 2: k1 ^= (key.charCodeAt(i + 1) & 0xff) << 8;
				case 1: k1 ^= (key.charCodeAt(i) & 0xff);

					k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff;
					k1 = (k1 << 15) | (k1 >>> 17);
					k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff;
					h1 ^= k1;
			}

			h1 ^= key.length;

			h1 ^= h1 >>> 16;
			h1 = (((h1 & 0xffff) * 0x85ebca6b) + ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) & 0xffffffff;
			h1 ^= h1 >>> 13;
			h1 = ((((h1 & 0xffff) * 0xc2b2ae35) + ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16))) & 0xffffffff;
			h1 ^= h1 >>> 16;

			return h1 >>> 0;
		},

		// https://bugzilla.mozilla.org/show_bug.cgi?id=781447
		hasLocalStorage: function () {
			try {
				return !!scope.localStorage;
			} catch (e) {
				return true; // SecurityError when referencing it means it exists
			}
		},

		hasSessionStorage: function () {
			try {
				return !!scope.sessionStorage;
			} catch (e) {
				return true; // SecurityError when referencing it means it exists
			}
		},

		isCanvasSupported: function () {
			var elem = document.createElement('canvas');
			return !!(elem.getContext && elem.getContext('2d'));
		},

		isIE: function () {
			if (navigator.appName === 'Microsoft Internet Explorer') {
				return true;
			} else if (navigator.appName === 'Netscape' && /Trident/.test(navigator.userAgent)) {// IE 11
				return true;
			}
			return false;
		},

		getPluginsString: function () {
			if (this.isIE()) {
				return this.getIEPluginsString();
			} else {
				return this.getRegularPluginsString();
			}
		},

		getRegularPluginsString: function () {
			return this.map(navigator.plugins, function (p) {
				var mimeTypes = this.map(p, function (mt) {
					return [mt.type, mt.suffixes].join('~');
				}).join(',');
				return [p.name, p.description, mimeTypes].join('::');
			}, this).join(';');
		},

		getIEPluginsString: function () {
			var names = ['ShockwaveFlash.ShockwaveFlash',//flash plugin
			  'AcroPDF.PDF', // Adobe PDF reader 7+
			  'PDF.PdfCtrl', // Adobe PDF reader 6 and earlier, brrr
			  'QuickTime.QuickTime', // QuickTime
			  // 5 versions of real players
			  'rmocx.RealPlayer G2 Control',
			  'rmocx.RealPlayer G2 Control.1',
			  'RealPlayer.RealPlayer(tm) ActiveX Control (32-bit)',
			  'RealVideo.RealVideo(tm) ActiveX Control (32-bit)',
			  'RealPlayer',
			  'SWCtl.SWCtl', // ShockWave player
			  'WMPlayer.OCX', // Windows media player
			  'AgControl.AgControl', // Silverlight
			  'Skype.Detection'];
			if (this.ie_activex && scope.ActiveXObject) {
				// starting to detect plugins in IE
				return this.map(names, function (name) {
					try {
						new ActiveXObject(name);
						return name;
					} catch (e) {
						return null;
					}
				}).join(';');
			} else {
				return ""; // behavior prior version 0.5.0, not breaking backwards compat.
			}
		},

		getScreenResolution: function () {
			return [screen.height, screen.width];
		},

		getCanvasFingerprint: function () {
			var canvas = document.createElement('canvas');
			var ctx = canvas.getContext('2d');
			// https://www.browserleaks.com/canvas#how-does-it-work
			var txt = 'http://valve.github.io';
			ctx.textBaseline = "top";
			ctx.font = "14px 'Arial'";
			ctx.textBaseline = "alphabetic";
			ctx.fillStyle = "#f60";
			ctx.fillRect(125, 1, 62, 20);
			ctx.fillStyle = "#069";
			ctx.fillText(txt, 2, 15);
			ctx.fillStyle = "rgba(102, 204, 0, 0.7)";
			ctx.fillText(txt, 4, 17);
			return canvas.toDataURL();
		}
	};


	if (typeof module === 'object' && typeof exports === 'object') {
		module.exports = Fingerprint;
	}
	scope.Fingerprint = Fingerprint;
})(window);

// +----------------------------------------------------------------------+
// | murmurHash3.js v2.1.1 (http://github.com/karanlyons/murmurHash.js)   |
// | A javascript implementation of MurmurHash3's x86 hashing algorithms. |
// |----------------------------------------------------------------------|
// | Copyright (c) 2012 Karan Lyons                                       |
// | Freely distributable under the MIT license.                          |
// +----------------------------------------------------------------------+


; (function (root, undefined) {
	'use strict';

	// Create a local object that'll be exported or referenced globally.
	var library = {
		'version': '2.1.1',
		'x86': {},
		'x64': {}
	};




	// PRIVATE FUNCTIONS
	// -----------------

	function _x86Multiply(m, n) {
		//
		// Given two 32bit ints, returns the two multiplied together as a
		// 32bit int.
		//

		return ((m & 0xffff) * n) + ((((m >>> 16) * n) & 0xffff) << 16);
	}


	function _x86Rotl(m, n) {
		//
		// Given a 32bit int and an int representing a number of bit positions,
		// returns the 32bit int rotated left by that number of positions.
		//

		return (m << n) | (m >>> (32 - n));
	}


	function _x86Fmix(h) {
		//
		// Given a block, returns murmurHash3's final x86 mix of that block.
		//

		h ^= h >>> 16;
		h = _x86Multiply(h, 0x85ebca6b);
		h ^= h >>> 13;
		h = _x86Multiply(h, 0xc2b2ae35);
		h ^= h >>> 16;

		return h;
	}


	function _x64Add(m, n) {
		//
		// Given two 64bit ints (as an array of two 32bit ints) returns the two
		// added together as a 64bit int (as an array of two 32bit ints).
		//

		m = [m[0] >>> 16, m[0] & 0xffff, m[1] >>> 16, m[1] & 0xffff];
		n = [n[0] >>> 16, n[0] & 0xffff, n[1] >>> 16, n[1] & 0xffff];
		var o = [0, 0, 0, 0];

		o[3] += m[3] + n[3];
		o[2] += o[3] >>> 16;
		o[3] &= 0xffff;

		o[2] += m[2] + n[2];
		o[1] += o[2] >>> 16;
		o[2] &= 0xffff;

		o[1] += m[1] + n[1];
		o[0] += o[1] >>> 16;
		o[1] &= 0xffff;

		o[0] += m[0] + n[0];
		o[0] &= 0xffff;

		return [(o[0] << 16) | o[1], (o[2] << 16) | o[3]];
	}


	function _x64Multiply(m, n) {
		//
		// Given two 64bit ints (as an array of two 32bit ints) returns the two
		// multiplied together as a 64bit int (as an array of two 32bit ints).
		//

		m = [m[0] >>> 16, m[0] & 0xffff, m[1] >>> 16, m[1] & 0xffff];
		n = [n[0] >>> 16, n[0] & 0xffff, n[1] >>> 16, n[1] & 0xffff];
		var o = [0, 0, 0, 0];

		o[3] += m[3] * n[3];
		o[2] += o[3] >>> 16;
		o[3] &= 0xffff;

		o[2] += m[2] * n[3];
		o[1] += o[2] >>> 16;
		o[2] &= 0xffff;

		o[2] += m[3] * n[2];
		o[1] += o[2] >>> 16;
		o[2] &= 0xffff;

		o[1] += m[1] * n[3];
		o[0] += o[1] >>> 16;
		o[1] &= 0xffff;

		o[1] += m[2] * n[2];
		o[0] += o[1] >>> 16;
		o[1] &= 0xffff;

		o[1] += m[3] * n[1];
		o[0] += o[1] >>> 16;
		o[1] &= 0xffff;

		o[0] += (m[0] * n[3]) + (m[1] * n[2]) + (m[2] * n[1]) + (m[3] * n[0]);
		o[0] &= 0xffff;

		return [(o[0] << 16) | o[1], (o[2] << 16) | o[3]];
	}


	function _x64Rotl(m, n) {
		//
		// Given a 64bit int (as an array of two 32bit ints) and an int
		// representing a number of bit positions, returns the 64bit int (as an
		// array of two 32bit ints) rotated left by that number of positions.
		//

		n %= 64;

		if (n === 32) {
			return [m[1], m[0]];
		}

		else if (n < 32) {
			return [(m[0] << n) | (m[1] >>> (32 - n)), (m[1] << n) | (m[0] >>> (32 - n))];
		}

		else {
			n -= 32;
			return [(m[1] << n) | (m[0] >>> (32 - n)), (m[0] << n) | (m[1] >>> (32 - n))];
		}
	}


	function _x64LeftShift(m, n) {
		//
		// Given a 64bit int (as an array of two 32bit ints) and an int
		// representing a number of bit positions, returns the 64bit int (as an
		// array of two 32bit ints) shifted left by that number of positions.
		//

		n %= 64;

		if (n === 0) {
			return m;
		}

		else if (n < 32) {
			return [(m[0] << n) | (m[1] >>> (32 - n)), m[1] << n];
		}

		else {
			return [m[1] << (n - 32), 0];
		}
	}


	function _x64Xor(m, n) {
		//
		// Given two 64bit ints (as an array of two 32bit ints) returns the two
		// xored together as a 64bit int (as an array of two 32bit ints).
		//

		return [m[0] ^ n[0], m[1] ^ n[1]];
	}


	function _x64Fmix(h) {
		//
		// Given a block, returns murmurHash3's final x64 mix of that block.
		// (`[0, h[0] >>> 1]` is a 33 bit unsigned right shift. This is the
		// only place where we need to right shift 64bit ints.)
		//

		h = _x64Xor(h, [0, h[0] >>> 1]);
		h = _x64Multiply(h, [0xff51afd7, 0xed558ccd]);
		h = _x64Xor(h, [0, h[0] >>> 1]);
		h = _x64Multiply(h, [0xc4ceb9fe, 0x1a85ec53]);
		h = _x64Xor(h, [0, h[0] >>> 1]);

		return h;
	}




	// PUBLIC FUNCTIONS
	// ----------------

	library.x86.hash32 = function (key, seed) {
		//
		// Given a string and an optional seed as an int, returns a 32 bit hash
		// using the x86 flavor of MurmurHash3, as an unsigned int.
		//

		key = key || '';
		seed = seed || 0;

		var remainder = key.length % 4;
		var bytes = key.length - remainder;

		var h1 = seed;

		var k1 = 0;

		var c1 = 0xcc9e2d51;
		var c2 = 0x1b873593;

		for (var i = 0; i < bytes; i = i + 4) {
			k1 = ((key.charCodeAt(i) & 0xff)) | ((key.charCodeAt(i + 1) & 0xff) << 8) | ((key.charCodeAt(i + 2) & 0xff) << 16) | ((key.charCodeAt(i + 3) & 0xff) << 24);

			k1 = _x86Multiply(k1, c1);
			k1 = _x86Rotl(k1, 15);
			k1 = _x86Multiply(k1, c2);

			h1 ^= k1;
			h1 = _x86Rotl(h1, 13);
			h1 = _x86Multiply(h1, 5) + 0xe6546b64;
		}

		k1 = 0;

		switch (remainder) {
			case 3:
				k1 ^= (key.charCodeAt(i + 2) & 0xff) << 16;

			case 2:
				k1 ^= (key.charCodeAt(i + 1) & 0xff) << 8;

			case 1:
				k1 ^= (key.charCodeAt(i) & 0xff);
				k1 = _x86Multiply(k1, c1);
				k1 = _x86Rotl(k1, 15);
				k1 = _x86Multiply(k1, c2);
				h1 ^= k1;
		}

		h1 ^= key.length;
		h1 = _x86Fmix(h1);

		return h1 >>> 0;
	};


	library.x86.hash128 = function (key, seed) {
		//
		// Given a string and an optional seed as an int, returns a 128 bit
		// hash using the x86 flavor of MurmurHash3, as an unsigned hex.
		//

		key = key || '';
		seed = seed || 0;

		var remainder = key.length % 16;
		var bytes = key.length - remainder;

		var h1 = seed;
		var h2 = seed;
		var h3 = seed;
		var h4 = seed;

		var k1 = 0;
		var k2 = 0;
		var k3 = 0;
		var k4 = 0;

		var c1 = 0x239b961b;
		var c2 = 0xab0e9789;
		var c3 = 0x38b34ae5;
		var c4 = 0xa1e38b93;

		for (var i = 0; i < bytes; i = i + 16) {
			k1 = ((key.charCodeAt(i) & 0xff)) | ((key.charCodeAt(i + 1) & 0xff) << 8) | ((key.charCodeAt(i + 2) & 0xff) << 16) | ((key.charCodeAt(i + 3) & 0xff) << 24);
			k2 = ((key.charCodeAt(i + 4) & 0xff)) | ((key.charCodeAt(i + 5) & 0xff) << 8) | ((key.charCodeAt(i + 6) & 0xff) << 16) | ((key.charCodeAt(i + 7) & 0xff) << 24);
			k3 = ((key.charCodeAt(i + 8) & 0xff)) | ((key.charCodeAt(i + 9) & 0xff) << 8) | ((key.charCodeAt(i + 10) & 0xff) << 16) | ((key.charCodeAt(i + 11) & 0xff) << 24);
			k4 = ((key.charCodeAt(i + 12) & 0xff)) | ((key.charCodeAt(i + 13) & 0xff) << 8) | ((key.charCodeAt(i + 14) & 0xff) << 16) | ((key.charCodeAt(i + 15) & 0xff) << 24);

			k1 = _x86Multiply(k1, c1);
			k1 = _x86Rotl(k1, 15);
			k1 = _x86Multiply(k1, c2);
			h1 ^= k1;

			h1 = _x86Rotl(h1, 19);
			h1 += h2;
			h1 = _x86Multiply(h1, 5) + 0x561ccd1b;

			k2 = _x86Multiply(k2, c2);
			k2 = _x86Rotl(k2, 16);
			k2 = _x86Multiply(k2, c3);
			h2 ^= k2;

			h2 = _x86Rotl(h2, 17);
			h2 += h3;
			h2 = _x86Multiply(h2, 5) + 0x0bcaa747;

			k3 = _x86Multiply(k3, c3);
			k3 = _x86Rotl(k3, 17);
			k3 = _x86Multiply(k3, c4);
			h3 ^= k3;

			h3 = _x86Rotl(h3, 15);
			h3 += h4;
			h3 = _x86Multiply(h3, 5) + 0x96cd1c35;

			k4 = _x86Multiply(k4, c4);
			k4 = _x86Rotl(k4, 18);
			k4 = _x86Multiply(k4, c1);
			h4 ^= k4;

			h4 = _x86Rotl(h4, 13);
			h4 += h1;
			h4 = _x86Multiply(h4, 5) + 0x32ac3b17;
		}

		k1 = 0;
		k2 = 0;
		k3 = 0;
		k4 = 0;

		switch (remainder) {
			case 15:
				k4 ^= key.charCodeAt(i + 14) << 16;

			case 14:
				k4 ^= key.charCodeAt(i + 13) << 8;

			case 13:
				k4 ^= key.charCodeAt(i + 12);
				k4 = _x86Multiply(k4, c4);
				k4 = _x86Rotl(k4, 18);
				k4 = _x86Multiply(k4, c1);
				h4 ^= k4;

			case 12:
				k3 ^= key.charCodeAt(i + 11) << 24;

			case 11:
				k3 ^= key.charCodeAt(i + 10) << 16;

			case 10:
				k3 ^= key.charCodeAt(i + 9) << 8;

			case 9:
				k3 ^= key.charCodeAt(i + 8);
				k3 = _x86Multiply(k3, c3);
				k3 = _x86Rotl(k3, 17);
				k3 = _x86Multiply(k3, c4);
				h3 ^= k3;

			case 8:
				k2 ^= key.charCodeAt(i + 7) << 24;

			case 7:
				k2 ^= key.charCodeAt(i + 6) << 16;

			case 6:
				k2 ^= key.charCodeAt(i + 5) << 8;

			case 5:
				k2 ^= key.charCodeAt(i + 4);
				k2 = _x86Multiply(k2, c2);
				k2 = _x86Rotl(k2, 16);
				k2 = _x86Multiply(k2, c3);
				h2 ^= k2;

			case 4:
				k1 ^= key.charCodeAt(i + 3) << 24;

			case 3:
				k1 ^= key.charCodeAt(i + 2) << 16;

			case 2:
				k1 ^= key.charCodeAt(i + 1) << 8;

			case 1:
				k1 ^= key.charCodeAt(i);
				k1 = _x86Multiply(k1, c1);
				k1 = _x86Rotl(k1, 15);
				k1 = _x86Multiply(k1, c2);
				h1 ^= k1;
		}

		h1 ^= key.length;
		h2 ^= key.length;
		h3 ^= key.length;
		h4 ^= key.length;

		h1 += h2;
		h1 += h3;
		h1 += h4;
		h2 += h1;
		h3 += h1;
		h4 += h1;

		h1 = _x86Fmix(h1);
		h2 = _x86Fmix(h2);
		h3 = _x86Fmix(h3);
		h4 = _x86Fmix(h4);

		h1 += h2;
		h1 += h3;
		h1 += h4;
		h2 += h1;
		h3 += h1;
		h4 += h1;

		return ("00000000" + (h2 >>> 0).toString(16)).slice(-8) + ("00000000" + (h1 >>> 0).toString(16)).slice(-8) + ("00000000" + (h4 >>> 0).toString(16)).slice(-8) + ("00000000" + (h3 >>> 0).toString(16)).slice(-8);
	};


	library.x64.hash128 = function (key, seed) {
		//
		// Given a string and an optional seed as an int, returns a 128 bit
		// hash using the x64 flavor of MurmurHash3, as an unsigned hex.
		//

		key = key || '';
		seed = seed || 0;

		var remainder = key.length % 16;
		var bytes = key.length - remainder;

		var h1 = [0, seed];
		var h2 = [0, seed];

		var k1 = [0, 0];
		var k2 = [0, 0];

		var c1 = [0x87c37b91, 0x114253d5];
		var c2 = [0x4cf5ad43, 0x2745937f];

		for (var i = 0; i < bytes; i = i + 16) {
			k1 = [((key.charCodeAt(i + 4) & 0xff)) | ((key.charCodeAt(i + 5) & 0xff) << 8) | ((key.charCodeAt(i + 6) & 0xff) << 16) | ((key.charCodeAt(i + 7) & 0xff) << 24), ((key.charCodeAt(i) & 0xff)) | ((key.charCodeAt(i + 1) & 0xff) << 8) | ((key.charCodeAt(i + 2) & 0xff) << 16) | ((key.charCodeAt(i + 3) & 0xff) << 24)];
			k2 = [((key.charCodeAt(i + 12) & 0xff)) | ((key.charCodeAt(i + 13) & 0xff) << 8) | ((key.charCodeAt(i + 14) & 0xff) << 16) | ((key.charCodeAt(i + 15) & 0xff) << 24), ((key.charCodeAt(i + 8) & 0xff)) | ((key.charCodeAt(i + 9) & 0xff) << 8) | ((key.charCodeAt(i + 10) & 0xff) << 16) | ((key.charCodeAt(i + 11) & 0xff) << 24)];

			k1 = _x64Multiply(k1, c1);
			k1 = _x64Rotl(k1, 31);
			k1 = _x64Multiply(k1, c2);
			h1 = _x64Xor(h1, k1);

			h1 = _x64Rotl(h1, 27);
			h1 = _x64Add(h1, h2);
			h1 = _x64Add(_x64Multiply(h1, [0, 5]), [0, 0x52dce729]);

			k2 = _x64Multiply(k2, c2);
			k2 = _x64Rotl(k2, 33);
			k2 = _x64Multiply(k2, c1);
			h2 = _x64Xor(h2, k2);

			h2 = _x64Rotl(h2, 31);
			h2 = _x64Add(h2, h1);
			h2 = _x64Add(_x64Multiply(h2, [0, 5]), [0, 0x38495ab5]);
		}

		k1 = [0, 0];
		k2 = [0, 0];

		switch (remainder) {
			case 15:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 14)], 48));

			case 14:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 13)], 40));

			case 13:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 12)], 32));

			case 12:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 11)], 24));

			case 11:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 10)], 16));

			case 10:
				k2 = _x64Xor(k2, _x64LeftShift([0, key.charCodeAt(i + 9)], 8));

			case 9:
				k2 = _x64Xor(k2, [0, key.charCodeAt(i + 8)]);
				k2 = _x64Multiply(k2, c2);
				k2 = _x64Rotl(k2, 33);
				k2 = _x64Multiply(k2, c1);
				h2 = _x64Xor(h2, k2);

			case 8:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 7)], 56));

			case 7:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 6)], 48));

			case 6:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 5)], 40));

			case 5:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 4)], 32));

			case 4:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 3)], 24));

			case 3:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 2)], 16));

			case 2:
				k1 = _x64Xor(k1, _x64LeftShift([0, key.charCodeAt(i + 1)], 8));

			case 1:
				k1 = _x64Xor(k1, [0, key.charCodeAt(i)]);
				k1 = _x64Multiply(k1, c1);
				k1 = _x64Rotl(k1, 31);
				k1 = _x64Multiply(k1, c2);
				h1 = _x64Xor(h1, k1);
		}

		h1 = _x64Xor(h1, [0, key.length]);
		h2 = _x64Xor(h2, [0, key.length]);

		h1 = _x64Add(h1, h2);
		h2 = _x64Add(h2, h1);

		h1 = _x64Fmix(h1);
		h2 = _x64Fmix(h2);

		h1 = _x64Add(h1, h2);
		h2 = _x64Add(h2, h1);

		return ("00000000" + (h1[0] >>> 0).toString(16)).slice(-8) + ("00000000" + (h1[1] >>> 0).toString(16)).slice(-8) + ("00000000" + (h2[0] >>> 0).toString(16)).slice(-8) + ("00000000" + (h2[1] >>> 0).toString(16)).slice(-8);
	};




	// INITIALIZATION
	// --------------

	// Export murmurHash3 for CommonJS, either as an AMD module or just as part
	// of the global object.
	if (typeof exports !== 'undefined') {
		if (typeof module !== 'undefined' && module.exports) {
			exports = module.exports = library;
		}

		exports.murmurHash3 = library;
	}

	else if (typeof define === 'function' && define.amd) {
		define([], function () {
			return library;
		});
	}

	else {
		// Use murmurHash3.noConflict to restore `murmurHash3` back to its
		// original value. Returns a reference to the library object, to allow
		// it to be used under a different name.
		library._murmurHash3 = root.murmurHash3

		library.noConflict = function () {
			root.murmurHash3 = library._murmurHash3;
			library._murmurHash3 = undefined;
			library.noConflict = undefined;

			return library;
		};

		root.murmurHash3 = library;
	}
})(this);


// runn the fingerprint to get the
var getFingerprint = function(){
    var my_hasher = murmurHash3.x64.hash128;
    var fp = new Fingerprint({ canvas: true, ie_activex: true, screen_resolution: true, hasher: my_hasher });
    var thisFingerprint = fp.get();
    
    console.log(thisFingerprint);

    return thisFingerprint;
}