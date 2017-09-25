/*
create by zhyuzh
v03
此项目仅限于项目工场教学使用，未经作者授权不得应用于任何商业用途
*/
package {

	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.utils.getDefinitionByName;
	import flash.system.ApplicationDomain;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.describeType;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class main extends MovieClip {
		private var that = this;

		private var pageNameRegx = /^\$(?:p|P|page|Page)_.+$/; //所有页面的类命名格式

		public var pageNameHisArr = [];
		public var curPagePos = -1;

		private var transTime = 0.5;
		private var trans = {
			'left': {
				'out': {
					type: Fly,
					direction: Transition.OUT,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 4
				},
				'in': {
					type: Fly,
					direction: Transition.IN,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 6
				}
			},
			'right': {
				'out': {
					type: Fly,
					direction: Transition.OUT,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 6
				},
				'in': {
					type: Fly,
					direction: Transition.IN,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 4
				}
			},
			'up': {
				'out': {
					type: Fly,
					direction: Transition.OUT,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 2
				},
				'in': {
					type: Fly,
					direction: Transition.IN,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 8
				}
			},
			'down': {
				'out': {
					type: Fly,
					direction: Transition.OUT,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 8
				},
				'in': {
					type: Fly,
					direction: Transition.IN,
					duration: transTime,
					easing: Regular.easeOut,
					startPoint: 2
				}
			},
			'fade': {
				'out': {
					type: Fade,
					direction: Transition.OUT,
					duration: transTime,
					easing: Regular.easeOut
				},
				'in': {
					type: Fade,
					direction: Transition.IN,
					duration: transTime,
					easing: Regular.easeOut
				}
			}
		}
		private var transTypeDefault = 'left';

		private var pageNameArr = [];
		private var pageClasses = {};
		private var pageMcs = {};

		public function main() {
			//兼容最初fly转场
			trans['fly'] = trans['left'];
			trans['fly2'] = trans['right'];

			getAllPages();
			addEventListener(MouseEvent.CLICK, click);

			//清除所有舞台页面，添加默认首页
			if (pageClasses['home']) {
				clearPages(that, []);
				var hm = new pageClasses['home']()
				that.addChildAt(hm, 0);

				pageMcs['home'] = hm;
				pageNameHisArr.push('home');
				curPagePos = 0;
			}
		}

		/*
		监听所有click事件，根据target对象名称自动执行跳转		
		*/
		private function click(evt) {
			var tar = getActionTarget(evt.target);
			if (!tar) return;

			var nm = tar.name;

			if (nm.substr(0, 3) == '$go') {
				var arr = nm.split('$');
				var aniType = arr.length > 2 ? arr[2] : transTypeDefault;

				var pname = arr[1].substring(arr[1].indexOf('_') + 1);
				if (!trans[aniType]) {
					trace('[zapp]ERR:$go换页找不到动作类型:' + pname + '!');
					return;
				}

				if (pname == 'back') { //后退处理
					gotoBack(tar, aniType);
				} else if (pageNameArr.indexOf(pname) != -1) { //换页处理
					gotoPage(pname, tar, aniType, true);
				} else {
					trace('[zapp]ERR:$go换页找不到页面:' + pname + '!');
				}
			} else if (nm.substr(0, 5) == '$this') { //动作处理
				parseAction(tar);
			}
		}

		/*
		尝试获取点击目标的上层是否具有$this动作命名
		*/
		private function getActionTarget(tar) {
			if (tar && tar.name && (tar.name.substr(0, 4) == '$go_' || tar.name.substr(0, 6) == '$this_')) {
				return tar;
			} else if (tar && tar.parent) {
				return getActionTarget(tar.parent);
			} else {
				return undefined;
			}
			return undefined;
		}



		/*
		处理后退，不计入历史HisArr
		*/
		private function gotoBack(tar, aniType) {
			var pos = curPagePos - 1;
			if (pos >= 0 && pos < pageNameHisArr.length) {
				gotoPage(pageNameHisArr[pos], tar, aniType, false);
				curPagePos = pos;
			} else {
				trace('[zapp]ERR:$go后退超出范围:' + tar.name + '!');
			}
		}


		/*
		处理动作：$开头支持click事件,$当前层，多一个向上一层，_下划线向下一层
		*/
		private function parseAction(tar) {
			var nm = tar.name;
			var mc = tar;
			var arr = nm.split('$');

			if (!arr || arr.length < 3) {
				trace('[zapp]ERR:$this动态命令格式错误:' + nm + '!');
				return;
			}

			//数组[0]为空，跳过
			var tarArr = arr[1].split('_');
			var paramStr = arr.length > 2 ? arr[2] : undefined;

			//模拟代码，这里指tar所在的父层
			var tarFn = tar.parent;
			for (var i = 1; i < tarArr.length; i++) {
				tarFn = tarFn[tarArr[i]];
				if (!tarFn) {
					trace('[zapp]ERR:$this动态命令格式找不到对象:' + nm + '!');
					return;
				}
			}

			try {
				if (paramStr) {
					tarFn(paramStr);
				} else {
					tarFn();
				}
			} catch (err) {
				trace('[zapp]ERR:$this动态命令执行失败:' + nm + '!');
			}
		}


		/*
		真正的换页函数
		*/
		private function gotoPage(pname, tar, aniType, addHis) {
			aniType = aniType ? aniType : transTypeDefault;
			var curPage = getParentPage(tar);
			var pageParent = curPage ? curPage.parent : that;
			var idx = 0;

			//当前页面消失
			if (curPage) {
				idx = pageParent.getChildIndex(curPage);
				TransitionManager.start(curPage, trans[aniType]['out']);
			} else {
				idx = getMaxPageIndex(pageParent);
			}

			var nexPage;
			if (pageMcs[pname]) {
				nexPage = pageMcs[pname];
			} else {
				nexPage = new pageClasses[pname]();
				pageMcs[pname] = nexPage;
			}

			//更新到历史记录,
			if (addHis) {
				if (curPagePos >= 0) { //curPos之后His都切除
					pageNameHisArr = pageNameHisArr.slice(0, curPagePos + 1);
				}
				pageNameHisArr.push(pname);
				curPagePos = pageNameHisArr.length - 1;
			}

			//新页面添加
			insertNexPage(pageParent, nexPage, curPage);
			TransitionManager.start(nexPage, trans[aniType]['in']);
		}


		/*
		重新排列各个子元素，将nexpage放在curpage之上;确保原有更高层元素不被遮挡
		*/
		private function insertNexPage(container, nexPage, curPage) {
			nexPage.parent == container && container.removeChild(nexPage); //提取下一页重新排序
			var nexPos = curPage && curPage.parent == container ? container.getChildIndex(curPage) : getMaxPageIndex(container);
			var childrenLen = container.numChildren ? container.numChildren : 0;
			var arr = [];
			for (var i = 0; i < childrenLen; i++) {
				var child = container.getChildAt(i);
				arr.push(child);
			}
			arr.splice(nexPos + 1, 0, nexPage);
			container.addChild(nexPage);
			for (var n = 0; n < arr.length; n++) {
				container.setChildIndex(arr[n], n);
			}
		}

		/*
		获取所有页面的最高zindex层级
		*/
		private function getMaxPageIndex(container) {
			var childrenLen = container.numChildren ? container.numChildren : 0;
			var max = -1;
			for (var i = 0; i < childrenLen; i++) {
				var pg = container.getChildAt(i);
				var clsNm = describeType(pg).@name;
				if (clsNm && clsNm.match(pageNameRegx)) {
					var zindex = pg.parent.getChildIndex(pg);
					if (zindex > max) {
						max = zindex;
					}
				}
			}
			return max;
		}



		/*
		初始化时候清除容器中当前页之外的所有页面；后期使用会导致scrollpane出错
		*/
		private function clearPages(container, leftArr, remove = true) {
			var childrenLen = container.numChildren ? container.numChildren : 0;
			var pgArr = [];
			for (var i = 0; i < childrenLen; i++) {
				var pg = container.getChildAt(i);
				var clsNm = describeType(pg).@name;
				if (clsNm && clsNm.match(pageNameRegx) && leftArr.indexOf(pg) == -1) {
					pgArr.push(pg);
				}
			}
			pgArr.forEach(function (pg) {
				if (remove) {
					container.removeChild(pg);
				} else {
					TransitionManager.start(pg, {
						type: Fly,
						direction: Transition.OUT,
						duration: 0.01,
						startPoint: 6
					});
				}
			})
		}


		/*
		递归检查父层对象，查找符合页面命名的层级，返回页面mc
		*/
		private function getParentPage(tar) {
			var p = tar.parent;
			if (!p) return undefined;

			var clsNm = describeType(p).@name;
			if (clsNm && clsNm.match(pageNameRegx)) {
				return p;
			} else {
				return getParentPage(p);
			};
		}

		/*
		获取所有页面名称和类；获取所有action按钮名称和类；
		*/
		private function getAllPages() {
			var nameArr = flash.system.ApplicationDomain.currentDomain.getQualifiedDefinitionNames();
			pageNameArr = [];
			pageClasses = {};
			nameArr.forEach(function (nm) {
				var cls: Class;
				if (nm.match(pageNameRegx)) {
					var pname = nm.substring(nm.indexOf('_') + 1);
					pageNameArr.push(pname);
					cls = getDefinitionByName(nm) as Class;
					pageClasses[pname] = cls;
				}
			});
			return null;
		}

	}
	//main class end

}