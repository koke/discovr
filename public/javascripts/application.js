// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function picture_over (image, photo_url) {
	image.style.width = '500px';
	image.style.position = 'absolute';
	image.style.zIndex = '10';
	image.src = photo_url;
	if (document.width < (image.x + 500)) { 
		image.style.left = (image.x - 425) + 'px'; 
		image.moved = true;
	}
}

function picture_out (image, photo_url) {
	image.style.width = '75px';
	image.style.position = 'relative';
	image.style.zIndex = '0';
	image.src = photo_url;
	if (image.moved) { 
		image.style.left = (image.x + 425) + 'px'; 
		image.moved = false;
	}
}

function setLoading (nsid) {
	var user = $(nsid);
	
	user.insert({
		top: "<div class='indicator'></div>"
	});
}

function endLoading(nsid) {
	$$('#' + nsid + ' .indicator').each(function(l) {
		l.remove();
	});
}

function startLoading (nsid) {
	$(nsid).className = 'loading';
}

function nsidLoaded(nsid) {
	$(nsid).className = 'loaded';
}

function nsidFailed(nsid) {
	$(nsid).className = 'failed';
}