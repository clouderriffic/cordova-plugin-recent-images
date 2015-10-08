/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

/*global cordova,window,console*/
/**
 * An Recent Images plugin for Cordova
 * 
 * Developed by Clouderriffic
 */

var RecentImages = function() {

};

/*
*	success - success callback
*	fail - error callback
*	options
*		.maximumImagesCount - max images to be selected, defaults to 15. If this is set to 1, 
*		                      upon selection of a single image, the plugin will return it.
*		.width - width to resize image to (if one of height/width is 0, will resize to fit the
*		         other while keeping aspect ratio, if both height and width are 0, the full size
*		         image will be returned)
*		.height - height to resize image to
*		.quality - quality of resized image, defaults to 100
*/
RecentImages.prototype.getRecentImages = function(success, fail, options) {
	if (!options) {
		options = {};
	}
	
	var params = {
		maximumImagesCount: options.maximumImagesCount ? options.maximumImagesCount : 10,
		width: options.width ? options.width : 800,
		height: options.height ? options.height : 800,
		quality: options.quality ? options.quality : 1.0
	};

	return cordova.exec(success, fail, "RecentImages", "getRecentImages", [params]);
};

window.recentImages = new RecentImages();
