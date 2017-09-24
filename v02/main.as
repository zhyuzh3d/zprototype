/*
create by zhyuzh
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

		private var pageNameRegx = /^\$(?:p|P|page|Page)_.+$/; //所有页面的类命名格式

		public var pageNameHisArr = [];
		public var curPagePos = -1;

		private var transTime = 0.5;
		private var trans = {
			'fly': {
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
			'fly2': {
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
			}
		}
		private var transTypeDefault = 'fly';

		private var pageNameArr = [];
		private var pageClasses = {};

		public function main() {
			getAllPages();
			addEventListener(MouseEvent.CLICK, click);

			//添加默认首页
			if (pageClasses['home']) {
				var hm = new pageClasses['home']()
				addChildAt(hm, 0);
				pageNameHisArr.push('home');
				curPagePos = 0;
			}
		}

		/*
		监听所有click事件，根据target对象名称自动执行跳转		
		*/
		private function click(evt) {
			var nm = evt.target.name;
			if (nm.substr(0, 3) == '$go') {
				var arr = nm.split('$');
				var aniType = arr.length > 2 ? arr[2] : transTypeDefault;

				var pname = arr[1].substring(arr[1].indexOf('_') + 1);
				if (!trans[aniType]) {
					trace('[zapp]ERR:$go换页找不到动作类型:' + pname + '!');
					return;
				}

				if (pname == 'back') { //后退处理
					gotoBack(evt.target, aniType);
				} else if (pageNameArr.indexOf(pname) != -1) { //换页处理
					gotoPage(pname, evt.target, aniType, true);
				} else {
					trace('[zapp]ERR:$go换页找不到页面:' + pname + '!');
				}
			} else if (nm.substr(0, 5) == '$this') { //动作处理
				parseAction(evt.target);
			}
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
			var p = curPage.parent;
			var idx = 0;

			//当前页面消失
			if (curPage) {
				idx = p.getChildIndex(curPage);
				TransitionManager.start(curPage, trans[aniType]['out']);
				var tmr = new Timer(transTime, 0);
				tmr.addEventListener(TimerEvent.TIMER_COMPLETE, function () {
					p.removeChild(curPage);
				});
			};

			var nexPage = new pageClasses[pname]();

			//更新到历史记录,
			if (addHis) {
				if (curPagePos >= 0) { //curPos之后His都切除
					pageNameHisArr = pageNameHisArr.slice(0, curPagePos + 1);
				}
				pageNameHisArr.push(pname);
				curPagePos = pageNameHisArr.length - 1;
			}

			//新页面添加
			p.addChildAt(nexPage, idx);
			TransitionManager.start(nexPage, trans[aniType]['in']);
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