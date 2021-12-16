/**
 * TakkoWidget v1.0.7
 * https://takko.app/
 * Author: pkc
 * 
 * Copyright Content Creators, Inc.
 * 
*/

class TakkoWidget {
	constructor() {
		this.takkoNode = document.querySelector('.takko-embed');
		this.parentNode = this.takkoNode.parentElement;
    this.width = 0;
    this.height = 0;
    this.origin = 'https://takko-staging-env.herokuapp.com';
    this.video = this.takkoNode.dataset.video;
    this.src = "";
  };

	init() {
		this.setup(this.parentNode);
	};

	setup(obj) {
		this.width = obj.clientWidth;
		this.height = obj.clientHeight;
		this.src = this.takkoNode.dataset.video;

		this.render();
		this.section();
	};

	render() {
		const frame = this.frame();
		this.parentNode.appendChild(frame);
	};

	frame() {
		const iframe = document.createElement('iframe');
		this.src = `${ this.origin }/embed/${ this.video }`;
		iframe.src = this.src;
		iframe.width = this.width;
		// iframe.height = (16/9)*this.width;
		iframe.height = this.width; // square
		iframe.frameBorder = 0;
		iframe.style = 'border-radius: 25px; border: 1px solid rgba(0,0,0,0.1);';
		iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
		return iframe;
	};

	section() {
		const section = this.takkoNode.querySelector('section');
		console.log('section: ' + section);
		section.remove();
	};
};

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
     const takkoWidget = new TakkoWidget();

     takkoWidget.init();
  };
};

// Compress for /widget.js using ECMAScript 2021 (via babel-minify) 
// https://jscompress.com
// Stats: 25.97% compression, saving 0.29 kb